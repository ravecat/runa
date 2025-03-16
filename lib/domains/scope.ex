defmodule Runa.Scope do
  @moduledoc """
  Defines the scope the caller to be used throughout the app.
  """
  use TypedStruct

  typedstruct do
    field :current_user, Ecto.Schema.t(), default: nil
    field :current_user_id, :integer, default: nil
  end

  def new(nil) do
    %__MODULE__{current_user: nil, current_user_id: nil}
  end

  def new(%Runa.Accounts.User{} = user) do
    %__MODULE__{current_user: user, current_user_id: user.id}
  end
end
