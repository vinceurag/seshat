defmodule Seshat.Providers.Facebook.Client do
  use Tesla, only: [:get, :post]

  plug(Tesla.Middleware.BaseUrl, "https://graph.facebook.com/v7.0")
  plug(Tesla.Middleware.JSON, engine: Jason, engine_opts: [keys: :atoms])
  plug(Tesla.Middleware.Query, access_token: page_access_token())

  @spec send_response(any, any) :: {:error, any} | {:ok, Tesla.Env.t()}
  def send_response(sender_id, response) do
    body = %{
      recipient: %{id: sender_id},
      messaging_type: "RESPONSE",
      message: response
    }

    post("/me/messages", body)
  end

  @spec get_profile(psid :: String.t()) :: {:ok, Tesla.Env.t()}
  def get_profile(psid) do
    get("/#{psid}", query: [fields: "first_name,last_name,profile_pic"])
  end

  defp page_access_token() do
    Application.get_env(:seshat, Seshat.Verification)[:page_access_token]
  end
end
