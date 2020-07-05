defmodule Seshat.Provider do
  @callback process_event(event :: map()) ::
              {:reply, recipient :: any(), response :: any()} | {:noreply, any()}

  @callback send(recipient :: any(), responses :: map() | [map()]) :: :ok
end
