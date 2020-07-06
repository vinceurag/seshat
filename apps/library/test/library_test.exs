defmodule LibraryTest do
  use ExUnit.Case

  @id "123"
  @title "The Vincy Code"
  @description "This most awesome book the world has seen."
  @author "Vincy Man"
  @isbn "123456789"
  @cover "http://covers.openlibrary.org/b/isbn/#{@isbn}-M.jpg"

  import Mox

  alias Library.Entities.{Book, Review}

  setup :verify_on_exit!

  describe "get_book_by_id/1" do
    test "returns book_not_found when book does not exist" do
      expect(Library.ProviderMock, :get_book_by_id, fn _ -> {:error, :book_not_found} end)
      assert {:error, :book_not_found} = Library.get_book_by_id(@id)
    end

    test "returns a book entity" do
      expect(Library.ProviderMock, :get_book_by_id, fn _ ->
        {:ok,
         %Book{
           id: @id,
           title: @title,
           excerpt: @description,
           cover: @cover,
           authors: [%{name: @author}]
         }}
      end)

      assert {:ok,
              %Book{
                id: @id,
                title: @title,
                excerpt: @description,
                cover: @cover,
                authors: [%{name: @author}]
              }} = Library.get_book_by_id(@id)
    end
  end

  describe "get_books_by_title/1" do
    test "returns books_not_found when nothing was found" do
      expect(Library.ProviderMock, :get_books_by_title, fn _ -> {:error, :books_not_found} end)

      assert {:error, :books_not_found} = Library.get_books_by_title("dummy title")
    end

    test "returns a list of books" do
      expect(Library.ProviderMock, :get_books_by_title, fn _ ->
        {:ok,
         [
           %Book{
             id: @id,
             title: @title,
             excerpt: nil,
             cover: @cover,
             authors: [%{name: @author}]
           }
         ]}
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
              ]} = Library.get_books_by_title("dummy title")
    end
  end

  describe "get_book_reviews/1" do
    test "returns book_not_found when nothing was found" do
      expect(Library.ProviderMock, :get_book_reviews, fn _ -> {:error, :book_not_found} end)

      assert {:error, :book_not_found} = Library.get_book_reviews(@id)
    end

    test "returns reviews_not_found when nothing was found" do
      expect(Library.ProviderMock, :get_book_reviews, fn _ -> {:error, :reviews_not_found} end)

      assert {:error, :reviews_not_found} = Library.get_book_reviews(@id)
    end

    test "returns a list of reviews" do
      id = "123"
      rating = 5
      author = "Vincy"
      body = "Awesome book"

      expect(Library.ProviderMock, :get_book_reviews, fn _ ->
        {:ok, [%Review{id: id, rating: rating, author: author, body: body}]}
      end)

      assert {:ok, [%Review{id: ^id, rating: ^rating, author: ^author, body: ^body}]} =
               Library.get_book_reviews(@id)
    end
  end
end
