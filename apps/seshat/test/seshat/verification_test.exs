defmodule Seshat.VerificationTest do
  use ExUnit.Case

  alias Seshat.Verification

  describe "verify/2" do
    test "returns error when token is nil" do
      assert {:error, "Neither mode/token should be nil"} = Verification.verify("subscribe", nil)
    end

    test "returns error when mode is nil" do
      assert {:error, "Neither mode/token should be nil"} =
               Verification.verify(nil, "dummy_token")
    end

    test "returns error when token is mismatched" do
      assert {:error, "Token mismatch"} = Verification.verify("subscribe", "dummy_token")
    end

    test "returns error when mode is invalid" do
      assert {:error, "Invalid mode"} = Verification.verify("dummy", verification_token())
    end

    test "returns :verified" do
      assert {:ok, verified} = Verification.verify("subscribe", verification_token())
    end
  end

  defp verification_token() do
    Application.get_env(:seshat, Seshat.Verification)[:verification_token]
  end
end
