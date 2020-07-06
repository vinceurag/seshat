defmodule Library.Providers.GoodreadsTest do
  use ExUnit.Case, async: false

  import Tesla.Mock

  alias Library.Providers.Goodreads
  alias Library.Entities.Book

  @id "123"
  @title "The Vincy Code"
  @description "This most awesome book the world has seen."
  @author "Vincy Man"
  @cover "https://goodreads.com/image/123"
  @non_existing_book_id "1000"
  @key Application.get_env(:library, Library.Providers.Goodreads)[:key]

  describe "get_book_by_id/1" do
    test "returns book_not_found when book does not exist" do
      mock(fn %{
                method: :get,
                url: "https://www.goodreads.com/book/show",
                query: [id: @non_existing_book_id, key: @key]
              } ->
        %Tesla.Env{status: 404, body: "<error>Page Not Found</error>"}
      end)

      assert {:error, :book_not_found} = Goodreads.get_book_by_id(@non_existing_book_id)
    end

    test "returns a book entity" do
      mock(fn %{
                method: :get,
                url: "https://www.goodreads.com/book/show"
              } ->
        %Tesla.Env{status: 200, body: sample_gr_response()}
      end)

      assert {:ok,
              %Book{
                id: @id,
                title: @title,
                excerpt: @description,
                cover: @cover,
                authors: [%{name: @author}]
              }} = Goodreads.get_book_by_id(@id)
    end
  end

  describe "get_books_by_title/1" do
    test "returns books_not_found when nothing was found" do
      mock(fn %{
                method: :get,
                url: "https://www.goodreads.com/search",
                query: [q: "dummy title", search: [field: "title"], key: @key]
              } ->
        %Tesla.Env{
          status: 200,
          body: """
          <GoodreadsResponse>
            <search>
              <results>
              </results>
            </search>
          </GoodreadsResponse>
          """
        }
      end)

      assert {:error, :books_not_found} = Goodreads.get_books_by_title("dummy title")
    end

    test "returns a list of books" do
      mock(fn %{
                method: :get,
                url: "https://www.goodreads.com/search",
                query: [q: "dummy title", search: [field: "title"], key: @key]
              } ->
        %Tesla.Env{
          status: 200,
          body: sample_search_response()
        }
      end)

      assert {:ok,
              [
                %Book{
                  id: @id,
                  title: @title,
                  excerpt: nil,
                  cover: @cover,
                  authors: [%{name: @author}]
                }
              ]} = Goodreads.get_books_by_title("dummy title")
    end
  end

  describe "get_book_reviews/1" do
    test "returns book_not_found when book does not exist" do
      mock(fn %{
                method: :get,
                url: "https://www.goodreads.com/book/reviews/#{@non_existing_book_id}",
                query: [text_only: true, sort: "newest", language_code: "en", key: @key]
              } ->
        %Tesla.Env{
          status: 404
        }
      end)

      {:error, :book_not_found} = Goodreads.get_book_reviews(@non_existing_book_id)
    end

    test "returns reviews_not_found when book does not have any reviews" do
      mock(fn %{
                method: :get,
                url: "https://www.goodreads.com/book/reviews/#{@id}",
                query: [text_only: true, sort: "newest", language_code: "en", key: @key]
              } ->
        %Tesla.Env{
          status: 200,
          body: """
          <GoodreadsResponse>
            <reviews>
            </reviews>
          </GoodreadsResponse>
          """
        }
      end)

      {:error, :reviews_not_found} = Goodreads.get_book_reviews(@id)
    end

    test "returns a list of reviews" do
      review_id = "123456"
      reviewer_name = "Vincy"
      rating = 5
      body = "Awesome book."

      mock(fn %{
                method: :get,
                url: "https://www.goodreads.com/book/reviews/#{@id}",
                query: [text_only: true, sort: "newest", language_code: "en", key: @key]
              } ->
        %Tesla.Env{
          status: 200,
          body: """
          <GoodreadsResponse>
            <reviews>
              <review>
                <id>#{review_id}</id>
                <user>
                  <display_name>#{reviewer_name}</display_name>
                </user>
                <rating>#{rating}</rating>
                <body>#{body}</body>
              </review>
            </reviews>
          </GoodreadsResponse>
          """
        }
      end)

      {:ok,
       [
         %Library.Entities.Review{
           author: ^reviewer_name,
           body: ^body,
           id: ^review_id,
           rating: ^rating
         }
       ]} = Goodreads.get_book_reviews(@id)
    end
  end

  defp sample_gr_response() do
    """
    <GoodreadsResponse>
      <book>
        <id>#{@id}</id>
        <title>#{@title}</title>
        <image_url>#{@cover}</image_url>
        <description>#{@description}</description>
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

  defp sample_search_response() do
    """
    <GoodreadsResponse>
      <search>
        <results>
          <work>
            <best_book>
              <id>#{@id}</id>
              <title>#{@title}</title>
              <image_url>#{@cover}</image_url>
              <description>#{@description}</description>
              <author>
                <name>#{@author}</name>
                <role></role>
              </author>
            </best_book>
          </work>
        </results>
      </search>
    </GoodreadsResponse>
    """
  end
end
