defmodule Seshat.Providers.Facebook.Entities.Profile do
  @type t() :: %__MODULE__{
          first_name: String.t(),
          last_name: String.t(),
          profile_pic: String.t()
        }

  @keys [:first_name, :last_name, :profile_pic]

  defstruct @keys
end
