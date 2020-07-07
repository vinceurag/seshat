defmodule Seshat.Providers.Facebook.Handler do
  @moduledoc """
  With the current scope of the project, we only need handlers
  for postbacks and text messages. In case you need to handle
  another kind of event, you just need to make sure that
  your new handler adheres to this behaviour.
  """

  @callback handle(user_data :: map(), event :: map()) ::
              {:reply, any(), any()} | {:noreply, any()}
end
