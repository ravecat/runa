ExUnit.configure(exclude: :skip, async: true, slowest: 10, slowest_modules: 10)

{:ok, _} = Application.ensure_all_started(:ex_machina)

ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(Runa.Repo, :manual)
