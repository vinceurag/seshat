defmodule Seshat.Verification do
  @moduledoc """
  This module handles the verification handshake
  """

  @spec verify(String.t(), String.t()) :: {:error, String.t()} | {:ok, :verified}
  def verify(mode, token) when is_binary(mode) and is_binary(token) do
    with :ok <- check_mode(mode),
         :ok <- check_token(token) do
      {:ok, :verified}
    end
  end

  def verify(_mode, _token), do: {:error, "Neither mode/token should be nil"}

  defp check_mode("subscribe"), do: :ok
  defp check_mode(_mode), do: {:error, "Invalid mode"}

  defp check_token(token) do
    if token == verification_token() do
      :ok
    else
      {:error, "Token mismatch"}
    end
  end

  defp verification_token() do
    Application.get_env(:seshat, Seshat.Verification)[:verification_token]
  end
end
