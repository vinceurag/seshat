defmodule Library.Providers.Goodreads do
  @behaviour Library.Provider

  import SweetXml

  alias Library.Providers.Goodreads.Client
  alias Library.Entities.{Book, Review}

  @spec get_book_by_id(id :: String.t()) :: {:ok, Book.t()} | {:error, :book_not_found}
  def get_book_by_id(id) do
    case Client.show_book(id) do
      {:ok, %Tesla.Env{status: 200, body: response}} ->
        book =
          response
          |> xmap(
            id: ~x"./book/id/text()"s,
            title: ~x"./book/title/text()"s,
            excerpt: ~x"./book/description/text()"s,
            cover: ~x"./book/image_url/text()"s,
            authors: [
              ~x"./book/authors/author"l,
              name: ~x"./name/text()"s,
              role: ~x"./role/text()"s
            ]
          )
          |> to_entity(Book)

        {:ok, book}

      _ ->
        {:error, :book_not_found}
    end
  end

  @spec get_books_by_title(title :: String.t()) :: {:ok, Book.t()} | {:error, :book_not_found}
  def get_books_by_title(title) do
    with {:ok, %Tesla.Env{body: response}} <- Client.search_books(title) do
      results =
        response
        |> xpath(
          ~x"//search/results/work"l,
          id: ~x"./best_book/id/text()"s,
          title: ~x"./best_book/title/text()"s,
          authors: ~x"./best_book/author/name/text()"s,
          cover: ~x"./best_book/image_url/text()"s
        )
        |> Enum.map(&to_entity(&1, Book))

      if Enum.empty?(results), do: {:error, :books_not_found}, else: {:ok, results}
    else
      _ ->
        {:error, :books_not_found}
    end
  end

  @spec get_book_reviews(book_id :: String.t()) ::
          {:ok, [Review.t()]} | {:error, :book_not_found} | {:error, :reviews_not_found}
  def get_book_reviews(book_id) do
    case Client.list_reviews(book_id) do
      {:ok, %Tesla.Env{status: 404}} ->
        {:error, :book_not_found}

      {:ok, %Tesla.Env{status: 200, body: response}} ->
        reviews =
          response
          |> xpath(
            ~x"//reviews/review"l,
            id: ~x"./id/text()"s,
            rating: ~x"./rating/text()"i,
            body: ~x"./body/text()"s,
            author: ~x"./user/display_name/text()"s
          )
          |> Enum.map(&to_entity(&1, Review))

        if Enum.empty?(reviews), do: {:error, :reviews_not_found}, else: {:ok, reviews}
    end
  end

  defp to_entity(map, Review) do
    %Review{
      id: map.id,
      rating: map.rating,
      body: String.trim(map.body),
      author: map.author
    }
  end

  defp to_entity(map, Book) do
    %Book{
      id: map.id,
      title: map.title,
      excerpt: map[:excerpt],
      cover: map.cover,
      authors: build_authors(map.authors)
    }
  end

  # Since Goodreads returns all authors in the same node,
  # this function would only retain main authors/co-authors.
  defp build_authors(authors) when is_list(authors) do
    Enum.map(authors, fn author ->
      if author.role == "", do: %{name: author.name}
    end)
    |> Enum.reject(&is_nil/1)
  end

  defp build_authors(author) when is_binary(author) do
    [%{name: author}]
  end
end
