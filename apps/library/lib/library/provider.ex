defmodule Library.Provider do
  @callback get_book_by_id(id :: String.t()) ::
              {:ok, Library.Entities.Book.t()} | {:error, :book_not_found}

  @spec get_book_by_id(id :: String.t()) ::
          {:ok, Library.Entities.Book.t()} | {:error, :book_not_found}
  def get_book_by_id(id) do
    provider().get_book_by_id(id)
  end

  defp provider() do
    Application.get_env(:library, :provider) || Library.Providers.Goodreads
  end
end
