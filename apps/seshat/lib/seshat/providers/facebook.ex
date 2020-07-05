defmodule Seshat.Providers.Facebook do
  @behaviour Seshat.Provider

  alias Seshat.ConversationStore
  alias Seshat.Providers.Facebook
  alias Seshat.Providers.Facebook.Handlers.{Message, Postback}

  @spec process_event(event :: map()) :: {:reply, any(), any()} | {:noreply, any()}
  def process_event(%{"message" => message} = event) do
    user_data = get_user_data(event)

    Message.handle(user_data, message)
  end

  def process_event(%{"postback" => postback} = event) do
    user_data = get_user_data(event)

    Postback.handle(user_data, postback)
  end

  @spec get_profile(sender_id :: String.t()) :: Facebook.Entities.Profile.t()
  def get_profile(user_id) do
    {:ok, response} = Facebook.Client.get_profile(user_id)

    %Facebook.Entities.Profile{
      first_name: response.body.first_name,
      last_name: response.body.last_name,
      profile_pic: response.body.profile_pic
    }
  end

  @spec send(recipient_id :: String.t(), responses :: map() | [map()]) :: :ok
  def send(recipient_id, responses) when is_list(responses) do
    Enum.each(responses, fn response ->
      formatted_response = Facebook.ResponseBuilder.build(response)

      Facebook.Client.send_response(recipient_id, formatted_response)
    end)
  end

  def send(recipient_id, response_struct) do
    response = Facebook.ResponseBuilder.build(response_struct)

    Facebook.Client.send_response(recipient_id, response)

    :ok
  end

  defp get_user_data(%{"sender" => %{"id" => sender_id}}) do
    case ConversationStore.get_user_data(sender_id) do
      {:ok, user_data} ->
        user_data

      {:error, _user_data_not_found} ->
        profile = Facebook.get_profile(sender_id)

        ConversationStore.save_user_data(sender_id, %{
          id: sender_id,
          profile: profile,
          intent: nil,
          variable: nil
        })
    end
  end
end
