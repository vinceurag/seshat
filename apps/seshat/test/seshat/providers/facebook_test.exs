defmodule Seshat.Providers.FacebookTest do
  use ExUnit.Case

  import Tesla.Mock
  import Mox

  alias Seshat.ConversationStore
  alias Seshat.Providers.Facebook

  alias Seshat.Providers.Facebook.Responses.{
    GenericTemplate,
    GenericTemplateElement,
    PostbackButton,
    QuickReply,
    Text
  }

  @sender_id "123"

  setup :verify_on_exit!

  setup do
    typing_on_body =
      Jason.encode!(%{
        recipient: %{id: @sender_id},
        sender_action: "typing_on"
      })

    typing_off_body =
      Jason.encode!(%{
        recipient: %{id: @sender_id},
        sender_action: "typing_off"
      })

    Tesla.Mock.mock(fn
      %{method: :get, url: "https://graph.facebook.com/v7.0/#{@sender_id}"} ->
        json(%{
          "first_name" => "Vincy",
          "last_name" => "Statham",
          "profile_pic" => "https://vin.cy/cv"
        })

      %{
        method: :post,
        url: "https://graph.facebook.com/v7.0/me/messages",
        body: ^typing_on_body
      } ->
        json(%{"recipient_id" => %{id: @sender_id}, "message_id" => "xxxx"})

      %{
        method: :post,
        url: "https://graph.facebook.com/v7.0/me/messages",
        body: ^typing_off_body
      } ->
        json(%{"recipient_id" => %{id: @sender_id}, "message_id" => "xxxx"})
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
      stub(Library.ProviderMock, :get_book_by_id, fn book_id ->
        {:ok,
         %Library.Entities.Book{
           id: book_id,
           title: "Title",
           authors: [%{name: "Vincy"}],
           excerpt: "Excerpt",
           cover: "https://vin.cy"
         }}
      end)

      assert {:reply, @sender_id,
              [
                %Seshat.Providers.Facebook.Responses.Text{text: "Hey Vincy!"},
                %Seshat.Providers.Facebook.Responses.QuickReply{
                  options: [
                    %{payload: "search_book_by_id", text: "By ID"},
                    %{payload: "search_book_by_title", text: "By Title"}
                  ],
                  text:
                    "Would you like to search a book by ID (from our good friends at Goodreads) or by title?"
                }
              ]} =
               Facebook.process_event(%{
                 "message" => %{"text" => "Hello!"},
                 "sender" => %{"id" => @sender_id}
               })
    end

    test "handles book id message when book was found" do
      book_id = "50"
      btn_postback = "evaluate_#{book_id}"
      modify_user_data(@sender_id, %{intent: "search_book_by_id"})

      expect(Library.ProviderMock, :get_book_by_id, fn book_id ->
        {:ok,
         %Library.Entities.Book{
           id: book_id,
           title: "Title",
           authors: [%{name: "Vincy"}, %{name: "Wency"}, %{name: "Boi"}],
           excerpt: "Excerpt",
           cover: "https://vin.cy"
         }}
      end)

      assert {:reply, @sender_id,
              [
                %Text{text: "It seems that you want to know my evaluation of this book:"},
                %GenericTemplate{
                  elements: [
                    %GenericTemplateElement{
                      subtitle: "by Vincy, Wency & Boi",
                      buttons: [
                        %PostbackButton{payload: ^btn_postback},
                        %PostbackButton{payload: "find_another_book"}
                      ]
                    }
                  ]
                }
              ]} =
               Facebook.process_event(%{
                 "message" => %{"text" => book_id},
                 "sender" => %{"id" => @sender_id}
               })
    end

    test "handles book id message when book was not found" do
      book_id = "50"
      modify_user_data(@sender_id, %{intent: "search_book_by_id"})

      expect(Library.ProviderMock, :get_book_by_id, fn _book_id ->
        {:error, :book_not_found}
      end)

      assert {:reply, @sender_id,
              %Text{text: "I can't seem to find the book. Can you tell me the book ID again?"}} =
               Facebook.process_event(%{
                 "message" => %{"text" => book_id},
                 "sender" => %{"id" => @sender_id}
               })
    end

    test "handles book title message when books were found" do
      book_title = "title"
      modify_user_data(@sender_id, %{intent: "search_book_by_title"})

      expect(Library.ProviderMock, :get_books_by_title, fn book_title ->
        {:ok,
         [
           %Library.Entities.Book{
             id: book_title,
             title: "Title",
             authors: [%{name: "Vincy"}],
             excerpt: "Excerpt",
             cover: "https://vin.cy"
           }
         ]}
      end)

      assert {:reply, @sender_id,
              [
                %Text{
                  text:
                    "I looked into the interwebs and found these... Which book would you like to evaluate?"
                },
                %GenericTemplate{} = generic_template
              ]} =
               Facebook.process_event(%{
                 "message" => %{"text" => book_title},
                 "sender" => %{"id" => @sender_id}
               })

      assert Enum.count(generic_template.elements) == 1
    end

    test "handles book title message when books were not found" do
      book_title = "title"
      modify_user_data(@sender_id, %{intent: "search_book_by_title"})

      expect(Library.ProviderMock, :get_books_by_title, fn _book_title ->
        {:error, :books_not_found}
      end)

      assert {:reply, @sender_id,
              %Text{
                text:
                  "I didn't find any books with that title. 😢 Can you tell me another book title?"
              }} =
               Facebook.process_event(%{
                 "message" => %{"text" => book_title},
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

    test "handles evaluate_<id> when book reviews are positive" do
      book_id = "1"

      stub(Library.ProviderMock, :get_book_reviews, fn _id -> {:ok, []} end)

      expect(Analyzer.ProviderMock, :get_sentiment, 1, fn _doc ->
        {:ok, %Analyzer.Entities.Sentiment{score: 100, label: :positive}}
      end)

      assert {:reply, @sender_id,
              [
                %Text{
                  text:
                    "According to my analysis of its reviews, it seems that a lot people liked this book. You might like it too!\n\nI recommend buying it. 😉"
                },
                %Text{text: "Just say hey when you need me again!"}
              ]} =
               Facebook.process_event(%{
                 "postback" => %{"payload" => "evaluate_#{book_id}"},
                 "sender" => %{"id" => @sender_id}
               })
    end

    test "handles evaluate_<id> when book reviews are neutral" do
      book_id = "1"

      stub(Library.ProviderMock, :get_book_reviews, fn _id -> {:ok, []} end)

      expect(Analyzer.ProviderMock, :get_sentiment, 1, fn _doc ->
        {:ok, %Analyzer.Entities.Sentiment{score: -100, label: :neutral}}
      end)

      assert {:reply, @sender_id,
              [
                %Text{
                  text:
                    "According to my analysis of its reviews, people are pretty neutral about this book. How about being the tie-breaker?\n\nAnyway, buy at your own risk. 😛"
                },
                %Text{text: "Just say hey when you need me again!"}
              ]} =
               Facebook.process_event(%{
                 "postback" => %{"payload" => "evaluate_#{book_id}"},
                 "sender" => %{"id" => @sender_id}
               })
    end

    test "handles evaluate_<id> when there are no book reviews" do
      book_id = "1"

      stub(Library.ProviderMock, :get_book_reviews, fn _id -> {:error, :reviews_not_found} end)

      assert {:reply, @sender_id,
              [
                %Text{
                  text:
                    "Hmmm. Interestingly, I cannot find any reviews for that book.\n\nI don't have any strong opinion about this. Let's just say, but at your own risk? 🤪"
                },
                %Text{text: "Just say hey when you need me again!"}
              ]} =
               Facebook.process_event(%{
                 "postback" => %{"payload" => "evaluate_#{book_id}"},
                 "sender" => %{"id" => @sender_id}
               })
    end

    test "handles evaluate_<id> when book reviews are negative" do
      book_id = "1"

      stub(Library.ProviderMock, :get_book_reviews, fn _id -> {:ok, []} end)

      expect(Analyzer.ProviderMock, :get_sentiment, 1, fn _doc ->
        {:ok, %Analyzer.Entities.Sentiment{score: -100, label: :negative}}
      end)

      assert {:reply, @sender_id,
              [
                %Text{
                  text:
                    "According to my analysis of its reviews, it seems that the majority of the people didn't like this book.\n\nThe final descision is still yours but I suggest finding another book. 😏"
                },
                %Text{text: "Just say hey when you need me again!"}
              ]} =
               Facebook.process_event(%{
                 "postback" => %{"payload" => "evaluate_#{book_id}"},
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
