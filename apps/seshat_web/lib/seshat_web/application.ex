defmodule SeshatWeb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Endpoint (http/https)
      SeshatWeb.Endpoint
      # Start a worker by calling: SeshatWeb.Worker.start_link(arg)
      # {SeshatWeb.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SeshatWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SeshatWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
