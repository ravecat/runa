defmodule RunaWeb.FeatureCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a full browser.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      @moduledoc false

      @endpoint RunaWeb.Endpoint
      @moduletag :e2e

      use Wallaby.Feature

      import Wallaby.Query
      import Runa.Factory

      setup _context do
        user = insert(:user)

        Application.put_env(:runa, :e2e_test_user_id, user.id)

        on_exit(fn -> Application.delete_env(:runa, :e2e_test_user_id) end)

        {:ok, user: user}
      end
    end
  end
end
