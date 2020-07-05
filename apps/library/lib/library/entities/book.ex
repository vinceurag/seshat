defmodule Library.Entities.Book do
  @type t() :: %__MODULE__{
          id: String.t(),
          title: String.t(),
          authors: [%{name: String.t()}],
          excerpt: String.t(),
          cover: String.t()
        }

  defstruct [:id, :title, :authors, :excerpt, :cover]
end
