defmodule Runa do
  @moduledoc """
  Runa keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def context do
    quote do
      import Ecto
      import Ecto.Query
      import Ecto.Changeset, except: [change: 2]

      alias Ecto.Multi
      alias Runa.Events
      alias Runa.JSONAPI
      alias Runa.Paginator
      alias Runa.PubSub
      alias Runa.Repo
      alias Runa.Scope

      import Runa.Paginator
    end
  end

  def schema do
    quote do
      use Ecto.Schema
      use TypedEctoSchema

      alias Runa.Repo

      import RunaWeb.Adapters.DateTime
      import Ecto.Changeset
      import Ecto.Query
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
