defmodule Seshat.Providers.FacebookTest do
  use ExUnit.Case

  import Tesla.Mock
  import Mox

  alias Seshat.ConversationStore
  alias Seshat.Providers.Facebook
  alias Seshat.Providers.Facebook.Responses.{GenericTemplate, QuickReply, Text}

  @sender_id "123"

  setup :verify_on_exit!

  setup do
    Tesla.Mock.mock(fn
      %{method: :get, url: "https://graph.facebook.com/v7.0/#{@sender_id}"} ->
        json(%{
          "first_name" => "Vincy",
          "last_name" => "Statham",
          "profile_pic" => "https://vin.cy/cv"
        })
    end)

    on_exit(fn ->
      :ets.delete_all_objects(:conversation_store)
    end)

    :ok
  end

  describe "send/2" do
    test "sends single text" do
      expect_message_to_be_sent_with(%{text: "Hello!"})

      Facebook.send(@sender_id, %Text{text: "Hello!"})
    end

    test "sends when list" do
      expect_message_to_be_sent_with(%{text: "Hello 1!"})

      Facebook.send(@sender_id, [%Text{text: "Hello 1!"}])
    end
  end

  describe "process_event/1 - message-type events" do
    test "handles message-type event" do
      stub(Seshat.BookFinderAdapterMock, :find_book_by_id, fn book_id ->
        {:ok,
         %{
           id: book_id,
           title: "Title",
           authors: [%{name: "Vincy"}],
           excerpt: "Excerpt",
           cover: "https://vin.cy"
         }}
      end)

      assert {:reply, @sender_id, %Text{text: "Hey Vincy!"}} =
               Facebook.process_event(%{
                 "message" => %{"text" => "Hello!"},
                 "sender" => %{"id" => @sender_id}
               })
    end

    test "handles book id message when book was found" do
      book_id = "50"
      modify_user_data(@sender_id, %{intent: "search_book_by_id"})

      expect(Seshat.BookFinderAdapterMock, :find_book_by_id, fn book_id ->
        {:ok,
         %{
           id: book_id,
           title: "Title",
           authors: [%{name: "Vincy"}],
           excerpt: "Excerpt",
           cover: "https://vin.cy"
         }}
      end)

      assert {:reply, @sender_id,
              [
                %Text{text: "It seems that you want to know my evaluation of this book:"},
                %GenericTemplate{},
                %QuickReply{}
              ]} =
               Facebook.process_event(%{
                 "message" => %{"text" => book_id},
                 "sender" => %{"id" => @sender_id}
               })
    end

    test "handles book id message when book was not found" do
      book_id = "50"
      modify_user_data(@sender_id, %{intent: "search_book_by_id"})

      expect(Seshat.BookFinderAdapterMock, :find_book_by_id, fn _book_id ->
        {:error, :book_not_found}
      end)

      assert {:reply, @sender_id,
              %Text{text: "I can't seem to find the book. Can you tell me the book ID again?"}} =
               Facebook.process_event(%{
                 "message" => %{"text" => book_id},
                 "sender" => %{"id" => @sender_id}
               })
    end

    test "handles search_book_by_title" do
      assert {:reply, @sender_id, %Text{text: "Cool! What's the book title?"}} =
               Facebook.process_event(%{
                 "message" => %{"quick_reply" => %{"payload" => "search_book_by_title"}},
                 "sender" => %{"id" => @sender_id}
               })
    end

    test "handles search_book_by_id" do
      assert {:reply, @sender_id, %Text{text: "Cool! What's the book ID?"}} =
               Facebook.process_event(%{
                 "message" => %{"quick_reply" => %{"payload" => "search_book_by_id"}},
                 "sender" => %{"id" => @sender_id}
               })
    end
  end

  describe "process_event/1 - postback-type events" do
    test "handles get_started" do
      assert {:reply, @sender_id, [%Text{}, %QuickReply{}]} =
               Facebook.process_event(%{
                 "postback" => %{"payload" => "get_started"},
                 "sender" => %{"id" => @sender_id}
               })
    end
  end

  defp expect_message_to_be_sent_with(expected_body) do
    mock(fn
      %{
        method: :post,
        url: "https://graph.facebook.com/v7.0/me/messages",
        body: body
      } ->
        body = Jason.decode!(body, keys: :atoms)
        assert expected_body == body.message

        json(%{"recipient_id" => body.recipient.id, "message_id" => "xxxx"})
    end)
  end

  defp modify_user_data(user_id, data) do
    case ConversationStore.get_user_data(user_id) do
      {:ok, user_data} ->
        new_data = Map.merge(user_data, data)
        ConversationStore.save_user_data(user_id, new_data)

      {:error, :user_data_not_found} ->
        new_data = %{
          id: user_id,
          profile: %{},
          intent: nil,
          variable: nil
        }

        ConversationStore.save_user_data(user_id, Map.merge(new_data, data))
    end
  end
end
