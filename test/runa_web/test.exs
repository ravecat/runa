defmodule RunaWeb.Projects do
  use RunaWeb.FeatureCase

  feature "projects page header", %{session: session} do
    session
    |> visit("/projects")
    |> find(Query.css("[aria-label='Projects']"))
    |> assert_text("Projects")
  end
end
