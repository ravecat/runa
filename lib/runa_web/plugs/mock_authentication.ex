defmodule RunaWeb.Plugs.MockAuthentication do
  @moduledoc """
  Authenticates a user during development and testing environments
  by automatically logging them in based on the environment configuration.
  """
  import Plug.Conn

  alias Runa.Accounts

  @dev_email Application.compile_env(:runa, :authentication)[:email]

  def init(opts), do: opts

  def call(%Plug.Conn{} = conn, _opts) do
    user = find_user_for_env()

    if user do
      conn
      |> put_session(:user_id, user.id)
      |> configure_session(renew: true)
    else
      conn
    end
  end

  defp find_user_for_env do
    case Mix.env() do
      :dev ->
        Accounts.get_by(email: @dev_email)

      :test ->
        case Application.get_env(:runa, :e2e_test_user_id) do
          nil -> nil
          user_id -> Accounts.get_by(id: user_id)
        end

      _ ->
        nil
    end
  end
end
