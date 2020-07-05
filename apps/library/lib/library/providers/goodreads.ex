defmodule Library.Providers.Goodreads do
  @behaviour Library.Provider

  import SweetXml

  alias Library.Providers.Goodreads.Client
  alias Library.Entities.Book

  @spec get_book_by_id(id :: String.t()) :: {:ok, Book.t()} | {:error, :book_not_found}
  def get_book_by_id(id) do
    with {:ok, %Tesla.Env{status: 200, body: response}} <- Client.show_book(id) do
      book =
        response
        |> xmap(
          id: ~x"./book/id/text()"s,
          title: ~x"./book/title/text()"s,
          excerpt: ~x"./book/description/text()"s,
          isbn: ~x"./book/isbn/text()"s,
          authors: [
            ~x"./book/authors/author"l,
            name: ~x"./name/text()"s,
            role: ~x"./role/text()"s
          ]
        )
        |> to_entity(Book)

      {:ok, book}
    else
      _ -> {:error, :book_not_found}
    end
  end

  defp to_entity(map, Book) do
    %Book{
      id: map.id,
      title: map.title,
      excerpt: map.excerpt,
      cover: "http://covers.openlibrary.org/b/isbn/#{map.isbn}-M.jpg",
      authors: build_authors(map.authors)
    }
  end

  # Since Goodreads returns all authors in the same node,
  # this function would only retain main authors/co-authors.
  defp build_authors(authors) do
    Enum.map(authors, fn author ->
      if author.role == "", do: %{name: author.name}
    end)
    |> Enum.reject(&is_nil/1)
  end
end
