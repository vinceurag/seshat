defmodule Seshat.Providers.Facebook.Responses.PostbackButton do
  @type t() :: %__MODULE__{
          text: String.t(),
          payload: String.t()
        }

  defstruct [:text, :payload]
end
