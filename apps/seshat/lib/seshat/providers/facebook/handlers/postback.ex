defmodule Seshat.Providers.Facebook.Handlers.Postback do
  @behaviour Seshat.Providers.Facebook.Handler

  alias Seshat.Providers.Facebook.Responses.{QuickReply, Text}

  @impl Seshat.Providers.Facebook.Handler
  def handle(user_data, %{"payload" => "evaluate_" <> book_id}) do
    response_1 = %Text{
      text: "Hey, so you are trying to evaluate book_id: #{book_id}"
    }

    {:reply, user_data.id, response_1}
  end

  @impl Seshat.Providers.Facebook.Handler
  def handle(user_data, %{"payload" => "get_started"}) do
    response_1 = %Text{
      text:
        "Hey #{user_data.profile.first_name}! My name is Seshat and I'm the goddess of writing. I'm here to help you evaluate books."
    }

    response_2 = %QuickReply{
      text:
        "Soooo... let me ask you. Would you like to search a book by ID (from our good friends at Goodreads) or by title?",
      options: [
        %{text: "By ID", payload: "search_book_by_id"},
        %{text: "By Title", payload: "search_book_by_title"}
      ]
    }

    {:reply, user_data.id, [response_1, response_2]}
  end
end
