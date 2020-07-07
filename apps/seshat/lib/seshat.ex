defmodule Seshat do
  @moduledoc """
  Seshat is the main entry point for the bot.
  """

  use GenServer

  def init(provider) do
    {:ok, provider}
  end

  def handle_cast({:start_processing, events}, provider) do
    Enum.each(events, fn %{"messaging" => messaging} ->
      msg_event = List.first(messaging)

      case provider.process_event(msg_event) do
        {:reply, recipient, response} ->
          provider.send(recipient, response)
          :ok

        {:noreply, _} ->
          :ok
      end
    end)

    {:stop, :normal, provider}
  end

  def start_link(provider) do
    GenServer.start_link(__MODULE__, provider)
  end

  def process(pid, events) do
    GenServer.cast(pid, {:start_processing, events})
  end
end
