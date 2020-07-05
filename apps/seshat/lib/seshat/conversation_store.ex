defmodule Seshat.ConversationStore do
  use GenServer

  require Logger

  @store :conversation_store

  @impl GenServer
  def init(_) do
    :ets.new(@store, [:set, :named_table, :public])
    Logger.info("ConversationStore initialized.")
    {:ok, nil}
  end

  def start() do
    Logger.info("Starting ConversationStore")
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def get_user_data(sender_id) do
    case :ets.lookup(@store, sender_id) do
      [] -> {:error, :user_data_not_found}
      [{^sender_id, user_data}] -> {:ok, user_data}
    end
  end

  def save_user_data(sender_id, data) do
    :ets.insert(@store, {sender_id, data})

    data
  end
end
