defmodule Runa.Events do
  @moduledoc """
  Defines Event structs for use within the pubsub system.
  """

  defmodule AccountCreated do
    @moduledoc false

    use TypedStruct

    typedstruct do
      field :data, Runa.Accounts.User.t(), enforce: true
    end
  end

  defmodule AccountUpdated do
    @moduledoc false

    use TypedStruct

    typedstruct do
      field :data, Runa.Accounts.User.t(), enforce: true
    end
  end

  defmodule ContributorCreated do
    @moduledoc false

    use TypedStruct

    typedstruct do
      field :data, Runa.Contributors.Contributor.t(), enforce: true
    end
  end

  defmodule ContributorUpdated do
    @moduledoc false

    use TypedStruct

    typedstruct do
      field :data, Runa.Contributors.Contributor.t(), enforce: true
    end
  end

  defmodule ContributorDeleted do
    @moduledoc false

    use TypedStruct

    typedstruct do
      field :data, Runa.Contributors.Contributor.t(), enforce: true
    end
  end

  defmodule ProjectCreated do
    @moduledoc false

    use TypedStruct

    typedstruct do
      field :data, Runa.Projects.Project.t(), enforce: true
    end
  end

  defmodule ProjectUpdated do
    @moduledoc false

    use TypedStruct

    typedstruct do
      field :data, Runa.Projects.Project.t(), enforce: true
    end
  end

  defmodule ProjectDeleted do
    @moduledoc false

    use TypedStruct

    typedstruct do
      field :data, Runa.Projects.Project.t(), enforce: true
    end
  end

  defmodule TeamCreated do
    @moduledoc false

    use TypedStruct

    typedstruct do
      field :data, Runa.Teams.Team.t(), enforce: true
    end
  end

  defmodule TeamUpdated do
    @moduledoc false

    use TypedStruct

    typedstruct do
      field :data, Runa.Teams.Team.t(), enforce: true
    end
  end

  defmodule TeamDeleted do
    @moduledoc false

    use TypedStruct

    typedstruct do
      field :data, Runa.Teams.Team.t(), enforce: true
    end
  end

  defmodule TokenCreated do
    @moduledoc false

    use TypedStruct

    typedstruct do
      field :data, Runa.Tokens.Token.t(), enforce: true
    end
  end

  defmodule TokenUpdated do
    @moduledoc false

    use TypedStruct

    typedstruct do
      field :data, Runa.Tokens.Token.t(), enforce: true
    end
  end

  defmodule TokenDeleted do
    @moduledoc false

    use TypedStruct

    typedstruct do
      field :data, Runa.Tokens.Token.t(), enforce: true
    end
  end

  defmodule InvitationCreated do
    @moduledoc false

    use TypedStruct

    typedstruct do
      field :data, Runa.Teams.Invitation.t(), enforce: true
    end
  end

  defmodule InvitationUpdated do
    @moduledoc false

    use TypedStruct

    typedstruct do
      field :data, Runa.Teams.Invitation.t(), enforce: true
    end
  end
end
