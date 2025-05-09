defmodule Runa.Teams.Invitations do
  @moduledoc """
  Context module for managing team invitations.
  """
  use Runa, :context

  alias Runa.Accounts.User
  alias Runa.Contributors
  alias Runa.Teams.Invitation

  @spec create_invitation(map()) ::
          {:ok, Invitation.t()} | {:error, Ecto.Changeset.t()}
  def create_invitation(attrs \\ %{}) do
    %Invitation{}
    |> Invitation.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, data} ->
        broadcast(%Events.InvitationCreated{data: data})

        {:ok, data}

      other ->
        other
    end
  end

  def update_invitation(invitation, attrs \\ %{}) do
    invitation
    |> change_invitation(attrs)
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking invitation changes.
  """
  def change_invitation(%Invitation{} = invitation, attrs \\ %{}) do
    Invitation.changeset(invitation, attrs)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for invitation forms.
  """
  @spec to_invite_changeset(map()) :: Ecto.Changeset.t()
  def to_invite_changeset(attrs \\ %{}) do
    Invitation.invite_changeset(attrs)
  end

  @doc """
  Retrieve invitation by token.
  """
  @spec get_invitation(String.t()) ::
          {:ok, Invitation.t()} | {:error, term()}
  def get_invitation(token) do
    case Repo.get_by(Invitation, token: token) do
      nil -> {:error, %Ecto.NoResultsError{}}
      invitation -> {:ok, invitation}
    end
  end

  @doc """
  Accept a pending invitation for an already authenticated user.
  """
  @spec accept_invitation(User.t(), Invitation.t()) ::
          {:ok, Invitation.t()} | {:error, any()}
  def accept_invitation(%User{id: user_id} = user, %Invitation{} = invitation) do
    with {:ok, _} <- check_invitation_status(invitation),
         {:ok, _} <- check_invitation_expiry(invitation),
         {:ok, _} <- check_invitee(user, invitation),
         {:ok, _} <-
           Contributors.create(Scope.new(user), %{
             user_id: user_id,
             team_id: invitation.team_id,
             role: invitation.role
           }),
         {:ok, updated_invitation} <-
           update_invitation(invitation, %{status: :accepted}) do
      {:ok, updated_invitation}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def make_mailing_list(%Scope{} = scope, attrs) do
    for email <- attrs["emails"] do
      create_invitation(%{
        "email" => email,
        "role" => attrs["role"],
        "team_id" => attrs["team_id"],
        "invited_by_user_id" => scope.current_user.id
      })
    end
  end

  defp check_invitation_status(invitation) do
    case invitation.status do
      :pending -> {:ok, invitation}
      _ -> {:error, "Invitation is noutdated"}
    end
  end

  defp check_invitation_expiry(invitation) do
    if DateTime.before?(invitation.inserted_at, DateTime.utc_now()) do
      {:ok, invitation}
    else
      {:error, "Invitation is outdated"}
    end
  end

  defp check_invitee(invitation, user) do
    if invitation.email == user.email do
      {:ok, invitation}
    else
      {:error, "Invitation created for another user"}
    end
  end

  @spec subscribe() :: :ok | {:error, term()}
  def subscribe() do
    PubSub.subscribe(topic())
  end

  @spec broadcast(term()) :: :ok | {:error, term()}
  defp broadcast(event) do
    PubSub.broadcast(topic(), event)
  end

  @spec topic() :: String.t()
  defp topic(),
    do: "#{Invitation.__schema__(:source)}"
end
