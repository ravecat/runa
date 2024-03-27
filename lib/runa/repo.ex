defmodule Runa.Repo do
  use Ecto.Repo,
    otp_app: :runa,
    adapter: Ecto.Adapters.Postgres
end
