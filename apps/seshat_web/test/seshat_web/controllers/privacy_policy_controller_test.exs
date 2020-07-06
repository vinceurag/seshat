defmodule SeshatWeb.PrivacyPolicyControllerTest do
  use SeshatWeb.ConnCase

  describe "show/2" do
    test "responds with the privacy policy", %{conn: conn} do
      conn =
        get(
          conn,
          Routes.privacy_policy_path(conn, :show, %{})
        )

      assert text_response(conn, 200) == "No data will be stored."
    end
  end
end
