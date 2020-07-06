defmodule AnalyzerTest do
  use ExUnit.Case

  alias Analyzer.Entities.Sentiment

  import Mox

  setup :verify_on_exit!

  describe "analyze/1" do
    test "returns cannot_analyze when provider fails" do
      expect(Analyzer.ProviderMock, :get_sentiment, 1, fn _doc -> {:error, :cannot_analyze} end)
      assert {:error, :cannot_analyze} = Analyzer.analyze("")
    end

    test "returns the Sentiment when provider succeeds" do
      score = 100
      label = :positive

      expect(Analyzer.ProviderMock, :get_sentiment, 1, fn _doc ->
        {:ok, %Sentiment{score: score, label: label}}
      end)

      assert {:ok, %Sentiment{score: ^score, label: ^label}} = Analyzer.analyze("Nice!")
    end
  end
end
