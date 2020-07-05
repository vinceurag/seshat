defmodule Library.Providers.Goodreads.Client do
  use Tesla

  plug(Tesla.Middleware.BaseUrl, "https://www.goodreads.com")
  plug(Tesla.Middleware.Query, key: key())

  @spec show_book(id :: String.t()) :: {:error, any} | {:ok, Tesla.Env.t()}
  def show_book(id) do
    get("/book/show", query: [id: id])
  end

  defp key() do
    Application.get_env(:library, Library.Providers.Goodreads)[:key]
  end
end
