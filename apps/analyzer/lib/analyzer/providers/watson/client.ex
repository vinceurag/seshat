defmodule Analyzer.Providers.Watson.Client do
  use Tesla, only: [:post]

  plug(Tesla.Middleware.BaseUrl, base_url())
  plug(Tesla.Middleware.BasicAuth, username: "apikey", password: api_key())
  plug(Tesla.Middleware.JSON, engine: Jason, engine_opts: [keys: :atoms])
  plug(Tesla.Middleware.Query, version: api_version())

  @spec analyze(document :: String.t()) :: {:error, any} | {:ok, Tesla.Env.t()}
  def analyze(document) do
    request_body = %{
      text: document,
      language: "en",
      features: %{
        sentiment: %{}
      }
    }

    post("/v1/analyze", request_body)
  end

  defp base_url() do
    Application.get_env(:analyzer, Analyzer.Providers.Watson)[:instance_url]
  end

  defp api_key() do
    Application.get_env(:analyzer, Analyzer.Providers.Watson)[:api_key]
  end

  defp api_version() do
    Application.get_env(:analyzer, Analyzer.Providers.Watson)[:api_version]
  end
end
