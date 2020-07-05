defmodule Seshat.BookFinder.LibraryAdapter do
  @behaviour Seshat.BookFinder

  @impl Seshat.BookFinder
  def find_book_by_id(id) do
    Library.get_book_by_id(id)
  end
end
