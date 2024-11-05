defmodule Runa.JSONAPI do
  @moduledoc false

  import Ecto.Query

  alias Runa.Repo
  alias RunaWeb.JSONAPI.Schemas.ResourceIdentifierObject

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
    end
  end

  @spec create_relationships(
          Ecto.Schema.t(),
          atom(),
          list(ResourceIdentifierObject.t()) | ResourceIdentifierObject.t()
        ) ::
          {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def create_relationships(parent_schema, key, attrs)
      when is_list(attrs) do
    ids = Enum.map(attrs, & &1["id"])

    child_schema = get_child_schema(parent_schema, key)

    current_relationships =
      Ecto.assoc(parent_schema, key) |> Repo.all()

    new_relationships = child_schema |> where([c], c.id in ^ids) |> Repo.all()

    updated_relationships = current_relationships ++ new_relationships

    parent_schema
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(key, updated_relationships)
    |> Repo.update()
  end

  @spec update_relationships(
          Ecto.Schema.t(),
          atom(),
          list(ResourceIdentifierObject.t())
        ) ::
          {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def update_relationships(parent_schema, key, attrs) when is_list(attrs) do
    ids = Enum.map(attrs, & &1["id"])

    child_schema = get_child_schema(parent_schema, key)

    new_relationships = child_schema |> where([c], c.id in ^ids) |> Repo.all()

    parent_schema
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(key, new_relationships)
    |> Repo.update()
  end

  @spec delete_relationships(
          Ecto.Schema.t(),
          atom(),
          list(ResourceIdentifierObject.t())
        ) ::
          {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def delete_relationships(parent_schema, key, attrs) when is_nil(attrs) do
    parent_schema
    |> Repo.preload(key)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_change(:"#{key}_id", nil)
    |> parent_schema.__struct__.changeset()
    |> Repo.update()
  end

  def delete_relationships(parent_schema, key, attrs) when attrs == [] do
    parent_schema
    |> Repo.preload(key)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(key, [])
    |> parent_schema.__struct__.changeset()
    |> Repo.update()
  end

  def delete_relationships(parent_schema, key, attrs) when is_list(attrs) do
    ids = Enum.map(attrs, & &1["id"])

    updated_relationships =
      Ecto.assoc(parent_schema, key)
      |> where([c], c.id not in ^ids)
      |> Repo.all()

    parent_schema
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(key, updated_relationships)
    |> Repo.update()
  end

  @spec get_child_schema(Ecto.Schema.t(), atom()) :: Ecto.Schema.t()
  defp get_child_schema(parent_schema, key) do
    parent_schema.__struct__.__schema__(
      :association,
      key
    ).related
  end
end
