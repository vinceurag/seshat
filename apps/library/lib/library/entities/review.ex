defmodule Library.Entities.Review do
  @type t() :: %__MODULE__{
          id: String.t(),
          rating: integer(),
          body: String.t(),
          author: String.t()
        }

  defstruct [:id, :rating, :body, :author]
end
