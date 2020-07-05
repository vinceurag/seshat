defmodule Seshat.Providers.Facebook.ClientTest do
  use ExUnit.Case

  alias Seshat.Providers.Facebook.Client

  import Tesla.Mock

  @text_response %{"text" => "Hello!"}
  @sender_id "123456"

  setup do
    mock(fn
      %{method: :post, url: "https://graph.facebook.com/v7.0/me/messages"} ->
        json(%{"recipient_id" => "1111", "message_id" => "2222"})
    end)

    :ok
  end

  describe "send_response/2" do
    test "includes a access_token as query parameter and response has recipient_id" do
      mock(fn
        %{
          method: :post,
          url: "https://graph.facebook.com/v7.0/me/messages",
          body: body,
          query: query
        } ->
          body = Jason.decode!(body, keys: :atoms)

          assert Keyword.has_key?(query, :access_token)

          json(%{"recipient_id" => body.recipient.id, "message_id" => "xxxx"})
      end)

      assert {:ok, %Tesla.Env{body: %{recipient_id: @sender_id}}} =
               Client.send_response(@sender_id, @text_response)
    end
  end

  describe "get_profile/1" do
    test "includes a access_token as query parameter" do
      mock(fn
        %{
          method: :get,
          url: "https://graph.facebook.com/v7.0/#{@sender_id}",
          query: query
        } ->
          assert Keyword.has_key?(query, :access_token)

          json(%{"message_id" => "xxxx"})
      end)

      Client.get_profile(@sender_id)
    end

    test "includes fields as query parameter" do
      mock(fn
        %{
          method: :get,
          url: "https://graph.facebook.com/v7.0/#{@sender_id}",
          query: query
        } ->
          assert Keyword.has_key?(query, :fields)
          assert query[:fields] == "first_name,last_name,profile_pic"

          json(%{"message_id" => "xxxx"})
      end)

      Client.get_profile(@sender_id)
    end

    test "returns first name, last name and profile pic" do
      first_name = "Vincy"
      last_name = "Urg"
      profile_pic = "https://placeholder.com/123"

      mock(fn
        %{
          method: :get,
          url: "https://graph.facebook.com/v7.0/#{@sender_id}"
        } ->
          json(%{
            "first_name" => first_name,
            "last_name" => last_name,
            "profile_pic" => profile_pic
          })
      end)

      assert {:ok,
              %Tesla.Env{
                body: %{first_name: ^first_name, last_name: ^last_name, profile_pic: ^profile_pic}
              }} = Client.get_profile(@sender_id)
    end
  end
end
