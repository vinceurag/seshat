defmodule LibraryTest do
  use ExUnit.Case

  import Tesla.Mock

  @id "123"
  @title "The Vincy Code"
  @description "This most awesome book the world has seen."
  @author "Vincy Man"
  @isbn "123456789"
  @cover "http://covers.openlibrary.org/b/isbn/#{@isbn}-M.jpg"
  @non_existing_book_id "1000"
  @key Application.get_env(:library, Library.Providers.Goodreads)[:key]

  setup do
    mock(fn
      %{
        method: :get,
        url: "https://www.goodreads.com/book/show",
        query: [id: "1000", key: @key]
      } ->
        %Tesla.Env{status: 404, body: "<error>Page Not Found</error>"}

      %{
        method: :get,
        url: "https://www.goodreads.com/book/show"
      } ->
        %Tesla.Env{status: 200, body: sample_gr_response()}
    end)

    :ok
  end

  describe "get_book_by_id/1" do
    test "returns error when book was not found" do
      assert {:error, :book_not_found} = Library.get_book_by_id(@non_existing_book_id)
    end

    test "returns a book map" do
      assert {:ok,
              %{
                id: @id,
                title: @title,
                excerpt: @description,
                cover: @cover,
                authors: [%{name: @author}]
              }} = Library.get_book_by_id(@id)
    end
  end

  defp sample_gr_response() do
    """
    <GoodreadsResponse>
      <book>
        <id>#{@id}</id>
        <title>#{@title}</title>
        <isbn>#{@isbn}</isbn>
        <description>#{@description}</description>
        <image_url>#{@cover}</image_url>
        <authors>
          <author>
            <name>#{@author}</name>
            <role></role>
          </author>
        </authors>
      </book>
    </GoodreadsResponse>
    """
  end
end
