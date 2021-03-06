defmodule SeshatWeb.Router do
  use SeshatWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SeshatWeb do
    pipe_through :api

    get "/webhook", WebhookController, :verify
    post "/webhook", WebhookController, :receive_event

    # needed so I can submit to facebook review
    get "/privacy_policy", PrivacyPolicyController, :show
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  # if Mix.env() in [:dev, :test] do
  #   import Phoenix.LiveDashboard.Router
end
