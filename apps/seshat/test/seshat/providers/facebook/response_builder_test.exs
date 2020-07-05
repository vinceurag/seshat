defmodule Seshat.Providers.Facebook.ResponseBuilderTest do
  use ExUnit.Case

  alias Seshat.Providers.Facebook.ResponseBuilder
  alias Seshat.Providers.Facebook.Responses.{GenericTemplate, GenericTemplateElement, Text, QuickReply}

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
    text = "Hello"
    subtitle = "It's me"
    image_url = "https://mario.com/woohoo"

    expected = %{
      attachment: %{
        type: "template",
        payload: %{
          template_type: "generic",
          image_aspect_ratio: "square",
          elements: [%{title: text, subtitle: subtitle, image_url: image_url}]
        }
      }
    }

    assert ^expected =
             ResponseBuilder.build(%GenericTemplate{elements: [%GenericTemplateElement{
              text: text,
              subtitle: subtitle,
              image_url: image_url
            }]})
  end

  describe "build/1 for GenericTemplateElement" do
    text = "Hello"
    subtitle = "It's me"
    image_url = "https://mario.com/woohoo"

    assert %{title: ^text, subtitle: ^subtitle, image_url: ^image_url}=
             ResponseBuilder.build(%GenericTemplateElement{
               text: text,
               subtitle: subtitle,
               image_url: image_url
             })
  end
end
