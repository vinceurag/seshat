defmodule Seshat.Providers.Facebook.Responses.GenericTemplateElement do
  alias Seshat.Providers.Facebook.Responses.PostbackButton

  @type t() :: %__MODULE__{
          text: String.t(),
          subtitle: String.t(),
          image_url: String.t(),
          buttons: [PostbackButton.t()]
        }

  defstruct [:text, :image_url, :subtitle, :buttons]
end
