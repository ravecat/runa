defmodule Runa.Repo do
  use Ecto.Repo,
    otp_app: :runa,
    adapter: Ecto.Adapters.Postgres

  import Ecto.Query

  @spec check_missing_resources(Ecto.Schema.t(), [String.t()]) ::
          [String.t()]
  def check_missing_resources(schema, ids) do
    existing_ids =
      from(e in schema, where: e.id in ^ids, select: e.id)
      |> __MODULE__.all()
      |> Enum.map(&to_string/1)
      |> MapSet.new()

    ids
    |> MapSet.new()
    |> MapSet.difference(existing_ids)
    |> MapSet.to_list()
  end

  @type merge_map :: %{
          optional(atom()) =>
            Ecto.Type.t()
            | (atom(), Ecto.Type.t(), Ecto.Type.t() -> Ecto.Type.t())
            | (Ecto.Changeset.t(), atom(), [Ecto.Schema.t()] ->
                 Ecto.Changeset.t())
        }
  @spec duplicate(Ecto.Schema.t()) ::
          {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  @spec duplicate(Ecto.Schema.t(), merge_map()) ::
          {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def duplicate(struct, attrs \\ %{}) when is_struct(struct) do
    associations = struct.__struct__.__schema__(:associations)

    struct = __MODULE__.preload(struct, associations)

    params =
      struct
      |> Map.from_struct()
      |> Map.merge(attrs)

    changeset =
      Ecto.Changeset.cast(
        struct.__struct__.__struct__,
        params,
        struct.__struct__.__schema__(:fields) -- [:id]
      )

    changeset =
      process_associations(associations, struct, changeset, attrs)

    __MODULE__.insert(changeset)
  end

  defp process_associations([], _struct, changeset, _attrs), do: changeset

  defp process_associations([assoc_name | rest], struct, changeset, attrs) do
    assoc = struct.__struct__.__schema__(:association, assoc_name)
    related_records = Map.get(struct, assoc_name)

    new_changeset =
      if assoc.relationship == :child do
        handle_child_assoc(changeset, assoc_name, related_records, attrs)
      else
        Ecto.Changeset.put_assoc(changeset, assoc_name, related_records)
      end

    process_associations(rest, struct, new_changeset, attrs)
  end

  defp handle_child_assoc(changeset, assoc_name, related_records, attrs) do
    attrs
    |> Map.get(assoc_name)
    |> case do
      f when is_function(f) ->
        f.(changeset, assoc_name, related_records)

      _ ->
        Ecto.Changeset.cast_assoc(changeset, assoc_name,
          with: fn child_struct, params ->
            belongs_to_fields = get_belongs_to_fields(child_struct)

            child_fields =
              child_struct.__struct__.__schema__(:fields) --
                [:id] -- belongs_to_fields

            params
            |> Map.from_struct()
            |> then(&Ecto.Changeset.cast(child_struct, &1, child_fields))
          end
        )
    end
  end

  @spec get_belongs_to_fields(Ecto.Schema.t()) :: [atom()]
  defp get_belongs_to_fields(struct) do
    struct.__struct__.__schema__(:associations)
    |> Enum.map(fn assoc ->
      struct.__struct__.__schema__(:association, assoc)
    end)
    |> Enum.filter(fn assoc ->
      assoc.owner_key != :id && assoc.relationship == :parent
    end)
    |> Enum.map(& &1.owner_key)
  end

  @spec get_by_association(
          Ecto.Schema.t(),
          atom(),
          Ecto.Query.dynamic_expr() | keyword()
        ) ::
          Ecto.Schema.t()
  def get_by_association(schema, association, filters) do
    query =
      from parent in schema,
        join: child in assoc(parent, ^association),
        where: ^filters,
        select: parent

    __MODULE__.all(query)
  end

  @spec maybe_preload(Ecto.Schema.t(), atom()) :: Ecto.Schema.t()
  def maybe_preload(data, association) do
    if(Ecto.assoc_loaded?(Map.get(data, association)),
      do: data,
      else: __MODULE__.preload(data, [association])
    )
  end
end
