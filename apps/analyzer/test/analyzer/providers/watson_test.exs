defmodule Analyzer.Providers.WatsonTest do
  use ExUnit.Case

  alias Analyzer.Entities.Sentiment
  import Tesla.Mock

  @instance_url Application.get_env(:analyzer, Analyzer.Providers.Watson)[:instance_url]

  describe "get_sentiment/1" do
    test "returns cannot_analyze when document is empty" do
      mock(fn
        %{
          method: :post,
          url: "#{@instance_url}/v1/analyze"
        } ->
          json(%{"error" => "invalid request: content is empty"}, status: 400)
      end)

      assert {:error, :cannot_analyze} = Analyzer.Providers.Watson.get_sentiment("")
    end

    test "returns sentiment" do
      score = 0.808402
      label = "positive"

      mock(fn
        %{
          method: :post,
          url: "#{@instance_url}/v1/analyze"
        } ->
          json(%{"sentiment" => %{"document" => %{"score" => score, "label" => label}}},
            status: 200
          )
      end)

      assert {:ok, %Sentiment{score: ^score, label: :positive}} =
               Analyzer.Providers.Watson.get_sentiment("Nice!")
    end
  end
end
