defmodule SeshatWeb.PrivacyPolicyController do
  use SeshatWeb, :controller

  def show(conn, _params) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(:ok, "No data will be stored.")
  end
end
