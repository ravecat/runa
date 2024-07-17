defmodule RunaWeb.ProjectController do
  use RunaWeb, :controller
  use RunaWeb, :openapi

  alias Runa.Projects
  alias Runa.Projects.Project
  alias RunaWeb.ProjectSerializer, as: Serializer
  alias RunaWeb.Schemas.Common, as: CommonSchemas
  alias RunaWeb.Schemas.Projects, as: ProjectSchemas

  plug JSONAPI.QueryParser, view: Serializer

  @tags [Serializer.type()]

  def show_operation() do
    %Operation{
      tags: @tags,
      summary: "Show project",
      description: "Show project details",
      operationId: "getTeam",
      parameters: [CommonSchemas.Params.path()],
      responses: %{
        200 =>
          response(
            "200 OK",
            "application/vnd.api+json",
            ProjectSchemas.ShowResponse
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
