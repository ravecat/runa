defmodule RunaWeb.Plugs.DevAuthentication do
  @moduledoc """
  Plug for authentication in development environment.
  """

  use RunaWeb, :controller

  alias Runa.Accounts

  @email Application.compile_env(:runa, :authentication)[:email]

  def call(conn, _opts) do
    cond do
      user = Mix.env() == :dev && Accounts.get_by(email: @email) ->
        conn
        |> put_session(:user_id, user.id)
        |> configure_session(renew: true)

      true ->
        conn
    end
  end
end
