defmodule Seshat.Providers.Facebook.ResponseBuilderTest do
  use ExUnit.Case

  alias Seshat.Providers.Facebook.ResponseBuilder

  alias Seshat.Providers.Facebook.Responses.{
    GenericTemplate,
    GenericTemplateElement,
    PostbackButton,
    Text,
    QuickReply
  }

  describe "build/1 for Text" do
    test "formats the response" do
      assert %{text: "Hello"} = ResponseBuilder.build(%Text{text: "Hello"})
    end
  end

  describe "build/1 for QuickReply" do
    test "formats with 2 options" do
      expected_map = %{
        text: "Please choose",
        quick_replies: [
          %{
            content_type: "text",
            title: "First Option",
            payload: "first_option"
          },
          %{
            content_type: "text",
            title: "Second Option",
            payload: "second_option"
          }
        ]
      }

      assert ^expected_map =
               ResponseBuilder.build(%QuickReply{
                 text: "Please choose",
                 options: [
                   %{text: "First Option", payload: "first_option"},
                   %{text: "Second Option", payload: "second_option"}
                 ]
               })
    end
  end

  describe "build/1 for GenericTemplate" do
    test "returns proper map" do
      text = "Hello"
      subtitle = "It's me"
      image_url = "https://mario.com/woohoo"

      expected = %{
        attachment: %{
          type: "template",
          payload: %{
            template_type: "generic",
            image_aspect_ratio: "square",
            elements: [%{title: text, subtitle: subtitle, image_url: image_url, buttons: []}]
          }
        }
      }

      assert ^expected =
               ResponseBuilder.build(%GenericTemplate{
                 elements: [
                   %GenericTemplateElement{
                     text: text,
                     subtitle: subtitle,
                     image_url: image_url,
                     buttons: []
                   }
                 ]
               })
    end
  end

  describe "build/1 for GenericTemplateElement" do
    test "returns proper map with no buttons" do
      text = "Hello"
      subtitle = "It's me"
      image_url = "https://mario.com/woohoo"

      assert %{title: ^text, subtitle: ^subtitle, image_url: ^image_url} =
               ResponseBuilder.build(%GenericTemplateElement{
                 text: text,
                 subtitle: subtitle,
                 image_url: image_url,
                 buttons: []
               })
    end

    test "returns proper map with 1 button" do
      text = "Hello"
      subtitle = "It's me"
      image_url = "https://mario.com/woohoo"
      btn_text = "click me"
      btn_payload = "hello_world_1"

      assert %{
               title: ^text,
               subtitle: ^subtitle,
               image_url: ^image_url,
               buttons: [%{type: "postback", title: ^btn_text, payload: ^btn_payload}]
             } =
               ResponseBuilder.build(%GenericTemplateElement{
                 text: text,
                 subtitle: subtitle,
                 image_url: image_url,
                 buttons: [
                   %PostbackButton{
                     text: btn_text,
                     payload: btn_payload
                   }
                 ]
               })
    end
  end

  describe "build/1 for PostbackButton" do
    text = "Hello"
    payload = "hello_world_1"

    assert %{type: "postback", title: ^text, payload: ^payload} =
             ResponseBuilder.build(%PostbackButton{
               text: text,
               payload: payload
             })
  end
end
