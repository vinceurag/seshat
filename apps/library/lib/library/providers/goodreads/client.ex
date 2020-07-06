defmodule Library.Providers.Goodreads.Client do
  use Tesla

  plug(Tesla.Middleware.BaseUrl, "https://www.goodreads.com")
  plug(Tesla.Middleware.Query, key: key())

  @spec show_book(id :: String.t()) :: {:ok, Tesla.Env.t()} | {:error, any}
  def show_book(id) do
    get("/book/show", query: [id: id])
  end

  @spec search_books(title :: String.t()) :: {:ok, Tesla.Env.t()} | {:error, any}
  def search_books(title) do
    get("/search", query: [q: title, search: [field: "title"]])
  end

  @spec list_reviews(book_id :: String.t()) :: {:ok, Tesla.Env.t()} | {:error, any}
  def list_reviews(book_id) do
    get("/book/reviews/#{book_id}", query: [text_only: true, sort: "newest", language_code: "en"])
  end

  defp key() do
    Application.get_env(:library, Library.Providers.Goodreads)[:key]
  end
end
