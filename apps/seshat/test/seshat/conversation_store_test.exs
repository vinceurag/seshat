defmodule Seshat.ConversationStoreTest do
  use ExUnit.Case

  alias Seshat.ConversationStore

  describe "start/0" do
    test "should return error since it must be started on app bootup" do
      assert {:error, {:already_started, pid}} = ConversationStore.start()
    end
  end

  describe "get_user_data/1" do
    test "returns error when no data was found" do
      assert {:error, :user_data_not_found} = ConversationStore.get_user_data("dummy")
    end

    test "returns the user data" do
      sender_id = "1234"
      data = %{dummy: "data"}
      ConversationStore.save_user_data(sender_id, data)

      assert {:ok, ^data} = ConversationStore.get_user_data(sender_id)
    end
  end

  describe "save_user_data/2" do
    test "saves the user data to the store" do
      sender_id = "1234"
      data = %{dummy: "data"}
      ConversationStore.save_user_data(sender_id, data)

      assert {:ok, ^data} = ConversationStore.get_user_data(sender_id)
    end

    test "replaces old data when it already exists" do
      sender_id = "1234"
      data = %{dummy: "data"}
      new_data = %{new_dummy: "new_data"}
      ConversationStore.save_user_data(sender_id, data)
      ConversationStore.save_user_data(sender_id, new_data)

      assert {:ok, ^new_data} = ConversationStore.get_user_data(sender_id)
    end
  end
end
