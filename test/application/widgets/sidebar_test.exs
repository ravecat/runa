defmodule RunaWeb.Widgets.Sidebar.Test do
  use RunaWeb.ConnCase

  import Phoenix.LiveViewTest

  alias RunaWeb.Components.Sidebar

  import Phoenix.LiveViewTest
  import Runa.Accounts.Fixtures

  defp create_user(_) do
    user = user_fixture()

    %{user: user}
  end

  describe "Sidebar" do
    setup [:create_user]

    test "renders menu items", %{user: user} do
      html = render_component(Sidebar, user: user)

      assert html =~ "Profile"
      assert html =~ "Projects"
      assert html =~ "Team"
      assert html =~ "Logout"
    end

    test "renders wokrspace info", %{user: user} do
      html = render_component(Sidebar, user: user)

      assert html =~ "#{user.name}"
      assert html =~ "owner"
      assert html =~ "#{user.name}&#39;s Team"
    end
  end
end
