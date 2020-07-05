defmodule Seshat.SeshatTest do
  use ExUnit.Case

  import Mox

  setup :verify_on_exit!

  describe "start_link/2" do
    test "starts the server with the correct provider" do
      dummy_provider = Fakebook

      assert {:ok, pid} = Seshat.start_link(dummy_provider)
      assert ^dummy_provider = :sys.get_state(pid)
    end
  end

  describe "process/2" do
    test "returns ok" do
      {:ok, pid} = Seshat.start_link(Fakebook)
      assert :ok = Seshat.process(pid, [%{}])
    end
  end

  describe "handle_cast/2" do
    test "stops the server" do
      Seshat.ProviderMock
      |> expect(:process_event, fn _ -> {:reply, "123", %{}} end)
      |> expect(:send, fn _, _ -> :ok end)

      assert {:stop, _, _} =
               Seshat.handle_cast(
                 {:start_processing, [%{"messaging" => [%{"messaging" => []}]}]},
                 Seshat.ProviderMock
               )
    end
  end

  describe "init/1" do
    test "returns an ok tuple with the provider" do
      dummy_provider = Fakebook

      assert {:ok, ^dummy_provider} = Seshat.init(dummy_provider)
    end
  end
end
