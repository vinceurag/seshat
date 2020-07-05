defmodule Seshat.Providers.Facebook.Handler do
  @callback handle(user_data :: map(), event :: map()) ::
              {:reply, any(), any()} | {:noreply, any()}
end
