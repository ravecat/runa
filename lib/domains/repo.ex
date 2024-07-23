defmodule Runa.Repo do
  use Ecto.Repo,
    otp_app: :runa,
    adapter: Ecto.Adapters.Postgres

  use Scrivener
end
