defmodule Seshat.Providers.Facebook.Responses.Text do
  @type t() :: %__MODULE__{
          text: String.t()
        }

  defstruct [:text]
end
