defmodule Analyzer.Entities.Sentiment do
  @type t() :: %__MODULE__{
          score: integer(),
          label: :positive | :neutral | :negative
        }

  defstruct [:score, :label]
end
