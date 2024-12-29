defmodule RunaWeb.Components.SelectTest do
  use RunaWeb.ComponentCase

  alias RunaWeb.Components.Select

  describe "compbox select" do
    test "renders contenteditable zone" do
      {:ok, view, _} =
        wrap_component(Select, :select, %{
          id: "test-select",
          type: "compbox",
          name: "test",
          value: ["Option 1"],
          options: [{"Option 1", "1"}, {"Option 2", "2"}],
          multiple: true,
          label: []
        })

      assert has_element?(view, "[contenteditable]")
    end

    test "renders hidden options zone" do
      {:ok, view, _} =
        wrap_component(Select, :select, %{
          id: "test-select",
          type: "compbox",
          name: "test",
          value: ["Option 1"],
          options: [{"Option 1", "1"}, {"Option 2", "2"}],
          multiple: true,
          label: []
        })

      assert has_element?(view, "select[aria-hidden=true]")
      assert has_element?(view, "select.hidden")
    end
  end
end
