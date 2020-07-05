defmodule Seshat.BookFinderTest do
  use ExUnit.Case

  import Mox

  setup :verify_on_exit!

  describe "find_book_by_id/1" do
    test "adapter must be called" do
      book_id = "50"

      expect(Seshat.BookFinderAdapterMock, :find_book_by_id, 1, fn b_id ->
        assert book_id == b_id

        {:error, :book_not_found}
      end)

      Seshat.BookFinder.find_book_by_id(book_id)
    end
  end
end
