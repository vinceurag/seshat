defmodule Seshat.Providers.Facebook.Handlers.Message do
  @behaviour Seshat.Providers.Facebook.Handler

  alias Seshat.ConversationStore
  alias Seshat.BookFinder

  alias Seshat.Providers.Facebook.Responses.{
    GenericTemplate,
    GenericTemplateElement,
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
  def handle(%{intent: "search_book_by_id"} = user_data, %{"text" => book_id}) do
    ConversationStore.save_user_data(user_data.id, %{user_data | variable: book_id})

    case BookFinder.find_book_by_id(book_id) do
      {:ok, book} ->
        response_1 = %Text{
          text: "It seems that you want to know my evaluation of this book:"
        }

        response_2 = %GenericTemplate{
          elements: [
            %GenericTemplateElement{
              text: book.title,
              image_url: book.cover,
              subtitle: "by #{build_author_name_subtitle(book.authors)}"
            }
          ]
        }

        response_3 = %QuickReply{
          text: "Am I correct?",
          options: [
            %{text: "Yes", payload: "accept_search_book_by_id"},
            %{text: "No", payload: "reject_search_book_by_id"}
          ]
        }

        {:reply, user_data.id, [response_1, response_2, response_3]}

      {:error, :book_not_found} ->
        response = %Text{
          text: "I can't seem to find the book. Can you tell me the book ID again?"
        }

        {:reply, user_data.id, response}
    end
  end

  @impl Seshat.Providers.Facebook.Handler
  def handle(user_data, %{"text" => _text}) do
    response = %Text{
      text: "Hey #{user_data.profile.first_name}!"
    }

    {:reply, user_data.id, response}
  end

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
