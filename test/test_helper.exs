Application.put_env(:wallaby, :base_url, RunaWeb.Endpoint.url())

{:ok, _} = Application.ensure_all_started(:ex_machina)
{:ok, _} = Application.ensure_all_started(:wallaby)

ExUnit.configure(exclude: [:skip], timeout: 10_000, async: true)

ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(Runa.Repo, :manual)

Repatch.setup()
Faker.start()
