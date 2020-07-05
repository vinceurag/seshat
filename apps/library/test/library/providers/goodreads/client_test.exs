defmodule Library.Providers.Goodreads.ClientTest do
  use ExUnit.Case

  import Tesla.Mock
  import SweetXml

  alias Library.Providers.Goodreads.Client

  @book_id "123"

  describe "show_book/1" do
    test "includes a access_token as query parameter" do
      mock(fn
        %{
          method: :get,
          url: "https://www.goodreads.com/book/show",
          query: query
        } ->
          assert Keyword.has_key?(query, :key)
      end)

      Client.show_book(@book_id)
    end

    test "response has book title" do
      mock(fn
        %{
          method: :get,
          url: "https://www.goodreads.com/book/show"
        } ->
          %Tesla.Env{body: sample_gr_response()}
      end)

      assert {:ok,
              %Tesla.Env{
                body: response
              }} = Client.show_book(@book_id)

      assert xpath(response, ~x"//book/title/text()"s) == "Hatchet"
    end
  end

  defp sample_gr_response() do
    """
    <GoodreadsResponse>
      <book>
        <id>50</id>
        <title>Hatchet</title>
        <description>This is the description.</description>
        <image_url>https://vin.cy/cv</image_url>
        <authors>
          <author>
            <name>Gary Paulsen</name>
          </author>
        </authors>
      </book>
    </GoodreadsResponse>
    """
  end
end
