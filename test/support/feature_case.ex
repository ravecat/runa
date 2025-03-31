defmodule RunaWeb.FeatureCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a full browser.
  """

  use ExUnit.CaseTemplate

  using options do
    quote do
      @moduledoc false

      @moduletag :e2e

      use Wallaby.Feature
      use Repatch.ExUnit

      # import Wallaby.Element
      import Wallaby.Query
      import Runa.Factory

      alias Runa.Repo
      alias Runa.Scope

      if unquote(options)[:auth] do
        setup do
          user = insert(:user)

          Application.put_env(:runa, :e2e_test_user_id, user.id)

          on_exit(fn -> Application.delete_env(:runa, :e2e_test_user_id) end)

          {:ok, user: user}
        end
      end
    end
  end
end
