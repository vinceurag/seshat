# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
use Mix.Config

config :seshat_web,
  generators: [context_app: :seshat]

# Configures the endpoint
config :seshat_web, SeshatWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "cdPHcQU7E84ZAj/A0jTDftJ693WSqL6skAXQwDmtwWGgDBwsEwm/+mspip3Qk4Ee",
  render_errors: [view: SeshatWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Seshat.PubSub,
  live_view: [signing_salt: "lH0WeFrU"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :seshat, Seshat.Verification,
  verification_token: System.get_env("VERIFICATION_TOKEN"),
  page_access_token: System.get_env("FB_ACCESS_TOKEN")

config :library, Library.Providers.Goodreads, key: System.get_env("GOODREADS_API_KEY")

config :analyzer, Analyzer.Providers.Watson,
  api_key: System.get_env("WATSON_API_KEY"),
  instance_url: System.get_env("WATSON_URL"),
  api_version: "2019-07-12"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
