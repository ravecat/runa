defmodule Runa.Tokens.Token do
  @moduledoc """
  The api tokens  schema.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @valid_access_levels Application.compile_env(:runa, :token_access_levels)
                       |> Map.values()

  schema "tokens" do
    field :token, :string
    field :access, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(token, attrs) do
    token
    |> cast(attrs, [:access])
    |> validate_required([:access, :token])
    |> validate_inclusion(:access, @valid_access_levels)
  end
end
