alias Seshat.Providers.Facebook

defprotocol Facebook.ResponseBuilder do
  @spec build(t) :: map()
  def build(entity)
end

defimpl Facebook.ResponseBuilder, for: Facebook.Responses.Text do
  def build(%Facebook.Responses.Text{text: text}) do
    %{text: text}
  end
end

defimpl Facebook.ResponseBuilder, for: Facebook.Responses.QuickReply do
  def build(%Facebook.Responses.QuickReply{text: text, options: options}) do
    formatted_options =
      Enum.map(options, fn option ->
        %{
          content_type: "text",
          title: option.text,
          payload: option.payload
        }
      end)

    %{
      text: text,
      quick_replies: formatted_options
    }
  end
end

defimpl Facebook.ResponseBuilder, for: Facebook.Responses.GenericTemplate do
  def build(%Facebook.Responses.GenericTemplate{elements: elements}) do
    %{
      attachment: %{
        type: "template",
        payload: %{
          template_type: "generic",
          image_aspect_ratio: "square",
          elements: Enum.map(elements, &Facebook.ResponseBuilder.build/1)
        }
      }
    }
  end
end

defimpl Facebook.ResponseBuilder, for: Facebook.Responses.GenericTemplateElement do
  def build(%Facebook.Responses.GenericTemplateElement{} = el) do
    %{title: el.text, image_url: el.image_url, subtitle: el.subtitle}
  end
end
