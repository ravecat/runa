defmodule RunaWeb.Components.SelectTest do
  use RunaWeb.ComponentCase

  alias RunaWeb.Components.Select

  describe "select" do
    test "renders combobox block" do
      {:ok, view, _} =
        wrap_component(Select, :select, %{
          id: "test-select",
          name: "test",
          value: ["Option 1"],
          options: [{"Option 1", "1"}, {"Option 2", "2"}],
          multiple: true,
          label: []
        })

      assert has_element?(view, "[role='combobox']")
    end

    test "renders listbox block" do
      {:ok, view, _} =
        wrap_component(Select, :select, %{
          id: "test-select",
          name: "test",
          value: ["Option 1"],
          options: [{"Option 1", "1"}, {"Option 2", "2"}],
          multiple: true,
          label: []
        })

      assert has_element?(view, "select[role='listbox']")
    end

    test "renders clear selection button" do
      {:ok, view, _} =
        wrap_component(Select, :select, %{
          id: "test-select",
          name: "test",
          value: ["Option 1"],
          options: [{"Option 1", "1"}, {"Option 2", "2"}],
          multiple: true,
          label: []
        })

      assert has_element?(view, "[aria-label='Clear selection']")
    end

    test "renders toggle options button" do
      {:ok, view, _} =
        wrap_component(Select, :select, %{
          id: "test-select",
          name: "test",
          value: ["Option 1"],
          options: [{"Option 1", "1"}, {"Option 2", "2"}],
          multiple: true,
          label: []
        })

      assert has_element?(view, "[aria-label='Toggle options']")
    end

    test "renders hidden options by default" do
      {:ok, view, _} =
        wrap_component(Select, :select, %{
          id: "test-select",
          name: "test",
          value: ["Option 1"],
          options: [{"Option 1", "1"}, {"Option 2", "2"}],
          multiple: true,
          label: []
        })

      assert has_element?(view, "select[aria-hidden=true]")
      assert has_element?(view, "select.hidden")
    end

    test "renders select without search field by default" do
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

      refute has_element?(view, "[role='combobox'] input")
    end

    test "renders search input with required option" do
      {:ok, view, _} =
        wrap_component(Select, :select, %{
          id: "test-select",
          type: "compbox",
          name: "test",
          value: ["Option 1"],
          options: [{"Option 1", "1"}, {"Option 2", "2"}],
          multiple: true,
          label: [],
          searchable: true
        })

      assert has_element?(view, "[role='combobox'] input")
    end

    test "sends clear selection event" do
      {:ok, view, _} =
        wrap_component(Select, :select, %{
          id: "test-select",
          name: "test",
          value: [],
          options: [{"Option 1", "1"}, {"Option 2", "2"}],
          multiple: false,
          label: [],
          searchable: true
        })

      view
      |> element("[aria-label='Clear selection']")
      |> render_click()

      assert_handle_event(view, "clear_selection", %{"id" => "test-select"})
    end

    test "sends input change text event" do
      {:ok, view, _} =
        wrap_component(Select, :select, %{
          id: "test-select",
          name: "test",
          value: [],
          options: [{"Option 1", "1"}, {"Option 2", "2"}],
          multiple: false,
          label: [],
          searchable: true
        })

      view
      |> element("[aria-label='Search options']")
      |> render_change(%{"test-select" => "example"})

      assert_handle_event(view, "search_options", %{"test-select" => "example"})
    end

    @tag :skip
    test "sends clear selection event with Repatch" do
      {:ok, view, _} =
        wrap_component(Select, :select, %{
          id: "test-select",
          name: "test",
          value: [],
          options: [{"Option 1", "1"}, {"Option 2", "2"}],
          multiple: false,
          label: [],
          searchable: true
        })

      Repatch.patch(Phoenix.LiveView.JS, :push, fn event, opts ->
        assert event == "clear_selection"
        assert opts == %{value: %{id: "test-select"}}
        Phoenix.LiveView.JS.push(event, opts)
      end)

      view
      |> element("[aria-label='Clear selection']")
      |> render_click()

      assert Repatch.called?(Phoenix.LiveView.JS, :push, 1)
    end
  end
end
