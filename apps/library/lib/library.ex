defmodule Library do
  @moduledoc """
  Library handles all book-related processes.
  """

  @callback get_book_by_id(id :: String.t()) :: {:ok, book()} | {:error, :book_not_found}

  alias Library.Entities.Book
  alias Library.Provider

  @type book() :: %{
          id: String.t(),
          title: String.t(),
          authors: [%{name: String.t()}],
          cover: String.t(),
          excerpt: String.t()
        }

  @doc """
  Gets the book from the provider by id.
  """
  @spec get_book_by_id(id :: String.t()) :: {:ok, book()} | {:error, :book_not_found}
  def get_book_by_id(id) do
    id
    |> Provider.get_book_by_id()
    |> to_response()
  end

  defp to_response({:ok, %Book{} = book}) do
    {:ok,
     %{
       id: book.id,
       title: book.title,
       authors: book.authors,
       excerpt: book.excerpt,
       cover: book.cover
     }}
  end

  defp to_response({:error, reason}), do: {:error, reason}
end
