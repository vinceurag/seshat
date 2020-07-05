use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :seshat_web, SeshatWeb.Endpoint,
  http: [port: 4002],
  server: false

config :tesla, adapter: Tesla.Mock

config :seshat, Seshat.BookFinder, adapter: Seshat.BookFinderAdapterMock

config :seshat, Seshat.Verification,
  verification_token: "dummy_verification_token",
  page_access_token: "dummy_access_token"

config :library, Library.Providers.Goodreads, key: "dummy_gr_key"

# Print only warnings and errors during test
config :logger, level: :warn
