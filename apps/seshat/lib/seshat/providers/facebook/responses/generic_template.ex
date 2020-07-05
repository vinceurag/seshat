defmodule Seshat.Providers.Facebook.Responses.GenericTemplate do
  alias Seshat.Providers.Facebook.Responses.GenericTemplateElement

  @type t() :: %__MODULE__{
          elements: [GenericTemplateElement.t()]
        }

  defstruct [:elements]
end
