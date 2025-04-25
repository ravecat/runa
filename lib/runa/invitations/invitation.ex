defmodule Runa.Invitations.Invitation do
  @moduledoc """
  Schema representing an invitation sent to a user to join a team.
  """
  use Runa, :schema

  @roles Runa.Contributors.Contributor.roles()
  @owner [owner: 8]
  @status [expired: 8, declined: 4, accepted: 2, pending: 1]

  typed_schema "invitations" do
    field :email, :string
    field :role, Ecto.Enum, values: @roles
    field :token, :string
    field :status, Ecto.Enum, values: @status, default: :pending
    field :expires_at, :utc_datetime_usec
    belongs_to :team, Runa.Teams.Team
    belongs_to :invited_by_user, Runa.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(invitation, attrs) do
    invitation
    |> cast(attrs, [:email, :role, :status, :team_id, :invited_by_user_id])
    |> validate_required([:email, :role])
    |> put_change(
      :token,
      :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)
    )
    |> put_change(:expires_at, DateTime.add(DateTime.utc_now(), 86400))
    |> validate_format(:email, ~r/@/)
  end

  @doc false
  def invite_changeset(attrs) do
    types = %{
      role: Ecto.ParameterizedType.init(Ecto.Enum, values: @roles ++ @owner),
      emails: {:array, :string}
    }

    {%{role: :viewer, emails: []}, types}
    |> cast(attrs, [:role, :emails])
    |> validate_required([:role, :emails])
    |> validate_length(:emails, min: 1)
    |> validate_list(:emails, fn changset ->
      validate_format(changset, :value, ~r/@/)
    end)
  end
end
