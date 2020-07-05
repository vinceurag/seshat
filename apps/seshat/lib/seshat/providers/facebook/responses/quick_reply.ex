defmodule Seshat.Providers.Facebook.Responses.QuickReply do
  @type t() :: %__MODULE__{
          text: String.t(),
          options: [%{text: String.t(), payload: String.t()}]
        }

  defstruct [:text, :options]
end
