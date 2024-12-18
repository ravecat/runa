defmodule Runa.RepoTest do
  use Runa.DataCase

  alias __MODULE__.Child
  alias __MODULE__.ManyToManyAssociation
  alias __MODULE__.Parent

  @moduletag :repo

  defmodule Parent do
    use Ecto.Schema

    schema "parents" do
      field :value, :string
      has_many :children, Child

      many_to_many :many_to_many_associations, ManyToManyAssociation,
        join_through: "many_to_many_associations_parents"
    end
  end

  defmodule Child do
    use Ecto.Schema

    schema "children" do
      field :value, :string
      belongs_to :parent, Parent
    end
  end

  defmodule ManyToManyAssociation do
    use Ecto.Schema

    schema "many_to_many_associations" do
      field :value, :string

      many_to_many :parents, Parent,
        join_through: "many_to_many_associations_parents"
    end
  end

  setup do
    Ecto.Adapters.SQL.query!(Repo, """
      CREATE TEMPORARY TABLE parents (
        id serial PRIMARY KEY,
        value text
      )
    """)

    Ecto.Adapters.SQL.query!(Repo, """
      CREATE TEMPORARY TABLE many_to_many_associations (
        id serial PRIMARY KEY,
        value text
      )
    """)

    Ecto.Adapters.SQL.query!(Repo, """
      CREATE TEMPORARY TABLE children (
        id serial PRIMARY KEY,
        parent_id integer REFERENCES parents(id),
        value text
      )
    """)

    Ecto.Adapters.SQL.query!(Repo, """
      CREATE TEMPORARY TABLE many_to_many_associations_parents (
        parent_id integer REFERENCES parents(id),
        many_to_many_association_id integer REFERENCES many_to_many_associations(id),
        PRIMARY KEY (parent_id, many_to_many_association_id)
      )
    """)

    :ok
  end

  describe "duplicate/2" do
    test "copies direct field values" do
      original = Repo.insert!(%Parent{value: "test value"})

      {:ok, duplicated} =
        Repo.duplicate(original)

      assert duplicated.id != original.id

      for field <- original.__struct__.__schema__(:fields), field != :id do
        assert Map.get(duplicated, field) == Map.get(original, field)
      end
    end

    test "replaces direct field value" do
      original = Repo.insert!(%Parent{value: "test value"})

      {:ok, duplicated} = Repo.duplicate(original, %{value: "new value"})

      assert duplicated.value == "new value"
    end

    test "handles many child associations" do
      parent = Repo.insert!(%Parent{value: "parent"})

      children = [
        Repo.insert!(%Child{value: "child 1", parent: parent}),
        Repo.insert!(%Child{value: "child 2", parent: parent})
      ]

      {:ok, duplicated} = Repo.duplicate(parent)

      for child <- duplicated.children do
        assert child not in children
        assert child.parent_id == duplicated.id
      end
    end

    test "handles many-to-many associations" do
      assocs = [
        Repo.insert!(%ManyToManyAssociation{value: "assoc 1"}),
        Repo.insert!(%ManyToManyAssociation{value: "assoc 2"})
      ]

      parent =
        Repo.insert!(%Parent{value: "parent"})
        |> Repo.preload(:many_to_many_associations)
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.put_assoc(:many_to_many_associations, assocs)
        |> Repo.update!()

      {:ok, duplicated} =
        Repo.duplicate(parent, %{
          many_to_many_associations: fn changeset, assoc_name, records ->
            Ecto.Changeset.put_assoc(changeset, assoc_name, records)
          end
        })

      duplicated = Repo.preload(duplicated, :many_to_many_associations)

      assert duplicated.many_to_many_associations ==
               parent.many_to_many_associations
    end

    test "handles belongs_to association" do
      parent = Repo.insert!(%Parent{value: "parent"})
      child = Repo.insert!(%Child{value: "child", parent: parent})

      {:ok, duplicated} = Repo.duplicate(child)

      assert duplicated.parent_id == child.parent_id
    end
  end
end
