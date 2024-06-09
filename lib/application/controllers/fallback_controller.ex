defmodule RunaWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use RunaWeb, :controller

  alias RunaWeb.{ErrorHTML, ErrorJSON}

  def call(conn, {:error, %Ecto.NoResultsError{}}) do
    conn
    |> put_status(404)
    |> put_view(html: ErrorHTML, json: ErrorJSON, jsonapi: ErrorJSON)
    |> render("404.json")
  end

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(422)
    |> put_view(json: ErrorJSON, jsonapi: ErrorJSON)
    |> render(:error, changeset: changeset)
  end
end
