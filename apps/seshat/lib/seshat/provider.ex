defmodule Seshat.Provider do
  @moduledoc """
  This is the Provider behaviour.
  If you're planning to plug-in another bot engine,
  just make sure it adheres to this contract.
  """

  @callback process_event(event :: map()) ::
              {:reply, recipient :: any(), response :: any()} | {:noreply, any()}

  @callback send(recipient :: any(), responses :: map() | [map()]) :: :ok
end
