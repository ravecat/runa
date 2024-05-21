ExUnit.configure(exclude: :skip, async: true)

ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(Runa.Repo, :manual)
