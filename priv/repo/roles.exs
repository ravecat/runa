alias Runa.Repo
alias Runa.Roles.Role

now = DateTime.truncate(DateTime.utc_now(), :second)

roles =
  Application.compile_env(:runa, :permissions)
  |> Map.values()
  |> Enum.map(fn title -> %{title: title, inserted_at: now, updated_at: now} end)

Repo.insert_all(Role, roles,
  on_conflict: {:replace_all_except, [:id, :title]},
  conflict_target: :title
)
