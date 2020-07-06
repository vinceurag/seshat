defmodule Library do
  @moduledoc """
  Library handles all book-related processes.
  """

  alias Library.Entities.{Book, Review}
  alias Library.Provider

  @doc """
  Gets the book from the provider by id.
  """
  @spec get_book_by_id(id :: String.t()) :: {:ok, Book.t()} | {:error, :book_not_found}
  def get_book_by_id(id) do
    Provider.get_book_by_id(id)
  end

  @spec get_books_by_title(title :: String.t()) :: {:ok, [Book.t()]} | {:error, :books_not_found}
  def get_books_by_title(title) do
    Provider.get_books_by_title(title)
  end

  @spec get_book_reviews(book_id :: String.t()) ::
          {:ok, [Review.t()]} | {:error, :book_not_found} | {:error, :reviews_not_found}
  def get_book_reviews(book_id) do
    Provider.get_book_reviews(book_id)
  end
end
