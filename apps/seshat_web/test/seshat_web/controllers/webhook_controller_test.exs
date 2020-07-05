defmodule SeshatWeb.WebhookControllerTest do
  use SeshatWeb.ConnCase

  @valid_query_params %{
    "hub.verify_token" => Application.get_env(:seshat, Seshat.Verification)[:verification_token],
    "hub.challenge" => "challenge",
    "hub.mode" => "subscribe"
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "receive_event/2" do
    test "responds with forbidden when event is not supported", %{conn: conn} do
      conn = post(conn, Routes.webhook_path(conn, :receive_event, %{"dummy" => "event"}))

      assert text_response(conn, 403) == "Event is not supported"
    end

    test "responds with success when event is supported", %{conn: conn} do
      conn =
        post(
          conn,
          Routes.webhook_path(conn, :receive_event, %{
            "object" => "page",
            "entry" => [%{"messaging" => [%{"text" => "event"}]}]
          })
        )

      assert text_response(conn, 200) == "Ok"
    end
  end

  describe "verify/2" do
    test "responds with failed verification when token is nil", %{conn: conn} do
      conn =
        get(
          conn,
          Routes.webhook_path(conn, :verify, %{@valid_query_params | "hub.verify_token" => nil})
        )

      assert text_response(conn, 403) == "Verification failed"
    end

    test "responds with failed verification when mode is nil", %{conn: conn} do
      conn =
        get(
          conn,
          Routes.webhook_path(conn, :verify, %{@valid_query_params | "hub.mode" => nil})
        )

      assert text_response(conn, 403) == "Verification failed"
    end

    test "responds with failed verification when mode is invalid", %{conn: conn} do
      conn =
        get(
          conn,
          Routes.webhook_path(conn, :verify, %{@valid_query_params | "hub.mode" => "invalid"})
        )

      assert text_response(conn, 403) == "Verification failed"
    end

    test "responds with failed verification when token is invalid", %{conn: conn} do
      conn =
        get(
          conn,
          Routes.webhook_path(conn, :verify, %{
            @valid_query_params
            | "hub.verify_token" => "invalid"
          })
        )

      assert text_response(conn, 403) == "Verification failed"
    end

    test "responds with failed verification when params are invalid", %{conn: conn} do
      conn =
        get(
          conn,
          Routes.webhook_path(conn, :verify, %{"hub.dummy_param" => "dummy"})
        )

      assert text_response(conn, 403) == "Verification failed"
    end

    test "responds with the challenge when everything is valid", %{conn: conn} do
      conn =
        get(
          conn,
          Routes.webhook_path(conn, :verify, @valid_query_params)
        )

      assert text_response(conn, 200) == @valid_query_params["hub.challenge"]
    end
  end
end
