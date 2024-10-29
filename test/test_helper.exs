ExUnit.configure(exclude: :skip, async: true)

{:ok, _} = Application.ensure_all_started(:ex_machina)

ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(Runa.Repo, :manual)
