defmodule Seshat.Providers.Facebook.Responses.GenericTemplateElement do
  @type t() :: %__MODULE__{
          text: String.t(),
          subtitle: String.t(),
          image_url: String.t()
        }

  defstruct [:text, :image_url, :subtitle]
end
