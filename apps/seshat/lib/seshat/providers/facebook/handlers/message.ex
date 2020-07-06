defmodule Seshat.Providers.Facebook.Handlers.Message do
  @behaviour Seshat.Providers.Facebook.Handler

  alias Seshat.ConversationStore

  alias Seshat.Providers.Facebook.Responses.{
    GenericTemplate,
    GenericTemplateElement,
    PostbackButton,
    QuickReply,
    Text
  }

  @impl Seshat.Providers.Facebook.Handler
  def handle(user_data, %{"quick_reply" => %{"payload" => "search_book_by_title"}}) do
    ConversationStore.save_user_data(user_data.id, %{user_data | intent: "search_book_by_title"})

    response = %Text{
      text: "Cool! What's the book title?"
    }

    {:reply, user_data.id, response}
  end

  @impl Seshat.Providers.Facebook.Handler
  def handle(user_data, %{"quick_reply" => %{"payload" => "search_book_by_id"}}) do
    ConversationStore.save_user_data(user_data.id, %{user_data | intent: "search_book_by_id"})

    response = %Text{
      text: "Cool! What's the book ID?"
    }

    {:reply, user_data.id, response}
  end

  @impl Seshat.Providers.Facebook.Handler
  def handle(%{intent: "search_book_by_title"} = user_data, %{"text" => title}) do
    ConversationStore.save_user_data(user_data.id, %{user_data | variable: title})

    case Library.get_books_by_title(title) do
      {:ok, books} ->
        top_five_books = Enum.take(books, 5)

        response_1 = %Text{
          text:
            "I looked into the interwebs and found these... Which book would you like to evaluate?"
        }

        template_elements =
          Enum.map(top_five_books, fn book ->
            %GenericTemplateElement{
              text: book.title,
              image_url: book.cover,
              subtitle: "by #{build_author_name_subtitle(book.authors)}",
              buttons: [
                %PostbackButton{text: "Evaluate this", payload: "evaluate_#{book.id}"},
                %PostbackButton{text: "Find Another Book", payload: "find_another_book"}
              ]
            }
          end)

        response_2 = %GenericTemplate{
          elements: template_elements
        }

        {:reply, user_data.id, [response_1, response_2]}

      {:error, :books_not_found} ->
        response = %Text{
          text: "I didn't find any books with that title. 😢 Can you tell me another book title?"
        }

        {:reply, user_data.id, response}
    end
  end

  @impl Seshat.Providers.Facebook.Handler
  def handle(%{intent: "search_book_by_id"} = user_data, %{"text" => book_id}) do
    ConversationStore.save_user_data(user_data.id, %{user_data | variable: book_id})

    case Library.get_book_by_id(book_id) do
      {:ok, book} ->
        response_1 = %Text{
          text: "It seems that you want to know my evaluation of this book:"
        }

        response_2 = %GenericTemplate{
          elements: [
            %GenericTemplateElement{
              text: book.title,
              image_url: book.cover,
              subtitle: "by #{build_author_name_subtitle(book.authors)}",
              buttons: [
                %PostbackButton{text: "Evaluate This", payload: "evaluate_#{book_id}"},
                %PostbackButton{text: "Find Another Book", payload: "find_another_book"}
              ]
            }
          ]
        }

        {:reply, user_data.id, [response_1, response_2]}

      {:error, :book_not_found} ->
        response = %Text{
          text: "I can't seem to find the book. Can you tell me the book ID again?"
        }

        {:reply, user_data.id, response}
    end
  end

  @impl Seshat.Providers.Facebook.Handler
  def handle(user_data, _any) do
    response_1 = %Text{
      text: "Hey #{user_data.profile.first_name}!"
    }

    response_2 = %QuickReply{
      text:
        "Would you like to search a book by ID (from our good friends at Goodreads) or by title?",
      options: [
        %{text: "By ID", payload: "search_book_by_id"},
        %{text: "By Title", payload: "search_book_by_title"}
      ]
    }

    {:reply, user_data.id, [response_1, response_2]}
  end

  defp build_author_name_subtitle([]), do: "No authors listed"

  defp build_author_name_subtitle([author | rest]) do
    _build_author_name_subtitle(author.name, rest)
  end

  defp _build_author_name_subtitle(author_text, []) do
    author_text
  end

  defp _build_author_name_subtitle(author_text, [author | []]) do
    _build_author_name_subtitle(author_text <> " & " <> author.name, [])
  end

  defp _build_author_name_subtitle(author_text, [author | rest]) do
    _build_author_name_subtitle(author_text <> ", " <> author.name, rest)
  end
end
