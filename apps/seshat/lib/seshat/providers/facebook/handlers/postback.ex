defmodule Seshat.Providers.Facebook.Handlers.Postback do
  @behaviour Seshat.Providers.Facebook.Handler

  alias Seshat.Providers.Facebook.Responses.{QuickReply, Text}
  alias Seshat.ConversationStore

  @impl Seshat.Providers.Facebook.Handler
  def handle(user_data, %{"payload" => "evaluate_" <> book_id}) do
    with {:ok, reviews} <- Library.get_book_reviews(book_id),
         stitched_reviews <- stitch_reviews(reviews),
         {:ok, sentiment} <- Analyzer.analyze(stitched_reviews) do
      response_text =
        case sentiment.label do
          :positive ->
            "According to my analysis of its reviews, it seems that a lot people liked this book. You might like it too!\n\nI recommend buying it. 😉"

          :neutral ->
            "According to my analysis of its reviews, people are pretty neutral about this book. How about being the tie-breaker?\n\nAnyway, buy at your own risk. 😛"

          :negative ->
            "According to my analysis of its reviews, it seems that the majority of the people didn't like this book.\n\nThe final descision is still yours but I suggest finding another book. 😏"
        end

      clean_user_data(user_data)

      {:reply, user_data.id,
       [%Text{text: response_text}, %Text{text: "Just say hey when you need me again!"}]}
    else
      _ ->
        {:reply, user_data.id,
         [
           %Text{
             text:
               "Hmmm. Interestingly, I cannot find any reviews for that book.\n\nI don't have any strong opinion about this. Let's just say, but at your own risk? 🤪"
           },
           %Text{text: "Just say hey when you need me again!"}
         ]}
    end
  end

  @impl Seshat.Providers.Facebook.Handler
  def handle(user_data, %{"payload" => "find_another_book"}) do
    {:reply, user_data.id,
     [%Text{text: "Sure thing, #{user_data.profile.first_name}."}, search_by_quick_reply()]}
  end

  @impl Seshat.Providers.Facebook.Handler
  def handle(user_data, %{"payload" => "get_started"}) do
    response_1 = %Text{
      text:
        "Hey #{user_data.profile.first_name}! My name is Seshat and I'm the goddess of writing. I'm here to help you evaluate books."
    }

    response_2 = search_by_quick_reply()

    {:reply, user_data.id, [response_1, response_2]}
  end

  defp search_by_quick_reply() do
    %QuickReply{
      text:
        "Soooo... let me ask you. Would you like to search a book by ID (from our good friends at Goodreads) or by title?",
      options: [
        %{text: "By ID", payload: "search_book_by_id"},
        %{text: "By Title", payload: "search_book_by_title"}
      ]
    }
  end

  defp clean_user_data(user_data) do
    cleaned_data = Map.merge(user_data, %{intent: nil, variable: nil})
    ConversationStore.save_user_data(user_data.id, cleaned_data)
  end

  defp stitch_reviews(reviews) do
    reviews
    |> Enum.map(& &1.body)
    |> Enum.join("\n")
  end
end
