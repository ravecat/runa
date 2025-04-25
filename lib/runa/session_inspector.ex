defmodule SessionInspector do
  @moduledoc """
  Debug utility for decoding Phoenix session cookies.

  ## Configuration

  Provide raw cookie, `signing_salt`, `secret_key_base` as function arguments.

  ## Usage
      Runa.SessionInspector.inspect(cookie, signing_salt, secret_key_base)
  """

  @doc """
  Decodes the signed session cookie.

  Returns `{:ok, map}` on success or `{:error, reason}`.
  """
  @spec decode(String.t(), String.t(), String.t()) ::
          {:ok, map()} | {:error, atom()}
  def decode(cookie, signing_salt, secret_key_base) when is_binary(cookie) do
    signing_key =
      Plug.Crypto.KeyGenerator.generate(secret_key_base, signing_salt)

    case String.split(cookie, ".", parts: 3) do
      [_, payload, signature] ->
        signed_value = "#{payload}--#{signature}"

        case Plug.Crypto.MessageVerifier.verify(signed_value, signing_key) do
          nil ->
            {:error, :invalid_signature}

          _unsigned ->
            with {:ok, raw} <- Base.url_decode64(payload, padding: false),
                 term <- :erlang.binary_to_term(raw) do
              {:ok, term}
            else
              :error -> {:error, :invalid_base64}
            end
        end

      _ ->
        {:error, :invalid_cookie_format}
    end
  end

  @doc """
  Decodes and prints the session data.
  """
  @spec inspect(String.t(), String.t(), String.t()) :: :ok | {:error, atom()}
  def inspect(cookie, signing_salt, secret_key_base) when is_binary(cookie) do
    case decode(cookie, signing_salt, secret_key_base) do
      {:ok, data} ->
        data

      {:error, reason} ->
        IO.puts("Failed to decode session: #{reason}")
        {:error, reason}
    end
  end
end
