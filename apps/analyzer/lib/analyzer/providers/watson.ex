defmodule Analyzer.Providers.Watson do
  @moduledoc """
  Connects to IBM's Watson
  """

  @behaviour Analyzer.Provider

  alias Analyzer.Entities.Sentiment
  alias Analyzer.Providers.Watson.Client

  @impl Analyzer.Provider
  def get_sentiment(document) do
    case Client.analyze(document) do
      {:ok, %Tesla.Env{status: 200, body: response}} ->
        {:ok, to_entity(response.sentiment.document, Sentiment)}

      _ ->
        {:error, :cannot_analyze}
    end
  end

  defp to_entity(map, Sentiment) do
    %Sentiment{
      score: map.score,
      label: String.to_existing_atom(map.label)
    }
  end
end
