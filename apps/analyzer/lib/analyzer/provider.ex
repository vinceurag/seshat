defmodule Analyzer.Provider do
  @moduledoc """
  This is the Provider behaviour.
  If you're planning to plug-in another sentiment analyzer provider,
  just make sure it adheres to this contract.
  """

  @callback get_sentiment(document :: String.t()) ::
              {:ok, Analyzer.Entities.Sentiment.t()} | {:error, :cannot_analyze}

  @spec get_sentiment(document :: String.t()) ::
          {:ok, Analyzer.Entities.Sentiment.t()} | {:error, :cannot_analyze}
  def get_sentiment(document) do
    provider().get_sentiment(document)
  end

  defp provider() do
    Application.get_env(:analyzer, :provider) || Analyzer.Providers.Watson
  end
end
