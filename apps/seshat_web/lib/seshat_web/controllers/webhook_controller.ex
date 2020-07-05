defmodule SeshatWeb.WebhookController do
  use SeshatWeb, :controller

  require Logger

  alias Seshat.Verification

  def receive_event(conn, %{"object" => "page", "entry" => entries}) do
    {:ok, pid} = Seshat.start_link(Seshat.Providers.Facebook)
    Seshat.process(pid, entries)

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(:ok, "Ok")
  end

  def receive_event(conn, _params) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(:forbidden, "Event is not supported")
  end

  def verify(conn, %{
        "hub.mode" => mode,
        "hub.verify_token" => token,
        "hub.challenge" => challenge
      }) do
    case Verification.verify(mode, token) do
      {:ok, :verified} ->
        Logger.info("Webhook challenge verified")

        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(:ok, challenge)

      {:error, reason} ->
        Logger.error(reason)

        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(:forbidden, "Verification failed")
    end
  end

  def verify(conn, _params) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(:forbidden, "Verification failed")
  end
end
