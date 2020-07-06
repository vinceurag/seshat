defmodule Library.Provider do
  @moduledoc """
  This is the Provider behaviour.
  If you're planning to plug-in another book finder (?) provider,
  just make sure it adheres to this contract.
  """

  @callback get_book_by_id(id :: String.t()) ::
              {:ok, Library.Entities.Book.t()} | {:error, :book_not_found}

  @callback get_books_by_title(title :: String.t()) ::
              {:ok, [Library.Entities.Book.t()]} | {:error, :books_not_found}

  @callback get_book_reviews(book_id :: String.t()) ::
              {:ok, [Library.Entities.Review.t()]}
              | {:error, :book_not_found}
              | {:error, :reviews_not_found}

  @spec get_book_by_id(id :: String.t()) ::
          {:ok, Library.Entities.Book.t()} | {:error, :book_not_found}
  def get_book_by_id(id) do
    provider().get_book_by_id(id)
  end

  @spec get_books_by_title(title :: String.t()) ::
          {:ok, [Library.Entities.Book.t()]} | {:error, :books_not_found}
  def get_books_by_title(title) do
    provider().get_books_by_title(title)
  end

  @spec get_book_reviews(book_id :: String.t()) ::
          {:ok, [Library.Entities.Review.t()]} | {:error, :book_not_found}
  def get_book_reviews(book_id) do
    provider().get_book_reviews(book_id)
  end

  defp provider() do
    Application.get_env(:library, :provider) || Library.Providers.Goodreads
  end
end
