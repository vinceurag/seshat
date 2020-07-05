defmodule Seshat.BookFinder do
  @callback find_book_by_id(id :: String.t()) :: {:ok, map()} | {:error, :book_not_found}

  def find_book_by_id(id) do
    adapter().find_book_by_id(id)
  end

  defp adapter() do
    Application.get_env(:seshat, Seshat.BookFinder)[:adapter] || Seshat.BookFinder.LibraryAdapter
  end
end
