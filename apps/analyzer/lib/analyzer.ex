defmodule Analyzer do
  @moduledoc """
  This app analyzes a document using Natural Language Processing (NLP).
  Right now it only has one available provider, IBM Watson.
  """

  alias Analyzer.Provider
  alias Analyzer.Entities.Sentiment

  @doc """
  Evaluates the document/text and returns a sentiment score.
  """
  @spec analyze(document :: String.t()) :: {:ok, Sentiment.t()} | {:error, :cannot_analyze}
  def analyze(document) do
    Provider.get_sentiment(document)
  end
end
