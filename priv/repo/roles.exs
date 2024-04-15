alias Runa.Repo
alias Runa.Accounts.Role

now = DateTime.utc_now() |> DateTime.truncate(:second)

roles = [
  %{title: "owner", inserted_at: now, updated_at: now},
  %{title: "admin", inserted_at: now, updated_at: now},
  %{title: "editor", inserted_at: now, updated_at: now},
  %{title: "reader", inserted_at: now, updated_at: now}
]

Repo.insert_all(Role, roles)
