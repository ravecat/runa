defmodule RunaWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use RunaWeb, :controller

  alias RunaWeb.{ErrorHTML, ErrorJSON, ChangesetJSON}

  def call(conn, {:error, %Ecto.NoResultsError{}}) do
    conn
    |> put_status(404)
    |> put_view(html: ErrorHTML, json: ErrorJSON, jsonapi: ErrorJSON)
    |> render(:"404")
  end

  def error(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: ChangesetJSON, jsonapi: ChangesetJSON)
    |> render(:error, changeset: changeset)
  end
end
