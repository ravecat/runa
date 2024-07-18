defmodule RunaWeb.ProjectController do
  use RunaWeb, :controller
  use RunaWeb, :openapi

  alias Runa.Projects
  alias Runa.Projects.Project
  alias RunaWeb.Schemas
  alias RunaWeb.Serializers

  plug JSONAPI.QueryParser, view: Serializers.Project

  @tags [Serializers.Project.type()]

  def show_operation() do
    %Operation{
      tags: @tags,
      summary: "Show project",
      description: "Show project details",
      operationId: "getTeam",
      parameters: [Schemas.Params.path()],
      responses: %{
        200 =>
          response(
            "200 OK",
            Schemas.Headers.content_type(),
            Schemas.Projects.ShowResponse
          )
      }
    }
  end

  def show(conn, %{id: id}) do
    with {:ok, project = %Project{}} <- Projects.get_project(id) do
      conn
      |> put_status(200)
      |> render(:show, data: project)
    end
  end
end
