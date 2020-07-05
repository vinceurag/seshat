defmodule Seshat.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the PubSub system
      {Phoenix.PubSub, name: Seshat.PubSub},
      # Start a worker by calling: Seshat.Worker.start_link(arg)
      # {Seshat.Worker, arg}
      %{
        id: Seshat.ConversationStore,
        start: {Seshat.ConversationStore, :start, []}
      }
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Seshat.Supervisor)
  end
end
