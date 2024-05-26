defmodule Runa.LocalesTest do
  @moduledoc false

  use Runa.DataCase

  alias Runa.{Locales.Locale, Locales}

  import Runa.{
    LocalesFixtures,
    ProjectsFixtures,
    LanguagesFixtures,
    TeamsFixtures
  }

  describe "locale context" do
    setup [
      :create_aux_team,
      :create_aux_project,
      :create_aux_language,
      :create_aux_locales
    ]

    test "returns all locales", ctx do
      assert Locales.get_locales() == [ctx.locale]
    end

    test "returns the locale with given id", ctx do
      assert Locales.get_locale!(ctx.locale.id) == ctx.locale
    end

    test "creates a locale with valid data", ctx do
      project = create_aux_project(%{team_id: ctx.team.id})
      language = create_aux_language()

      valid_attrs = %{project_id: project.id, language_id: language.id}

      assert {:ok, %Locale{}} = Locales.create_locale(valid_attrs)
    end

    test "returns error changeset during creation with invalid data" do
      invalid_attrs = %{}

      assert {:error, %Ecto.Changeset{}} = Locales.create_locale(invalid_attrs)
    end

    test "updates the locale with valid data", ctx do
      project = create_aux_project(%{team_id: ctx.team.id})

      update_attrs = %{
        project_id: project.id
      }

      assert {:ok, %Locale{} = locale} =
               Locales.update_locale(ctx.locale, update_attrs)

      assert locale.project_id == project.id
    end

    test "returns error changeset during update with invalid data", ctx do
      invalid_attrs = %{project_id: nil, language_id: nil}

      assert {:error, %Ecto.Changeset{}} =
               Locales.update_locale(ctx.locale, invalid_attrs)

      assert ctx.locale == Locales.get_locale!(ctx.locale.id)
    end

    test "deletes the locale", ctx do
      assert {:ok, %Locale{}} = Locales.delete_locale(ctx.locale)

      assert_raise Ecto.NoResultsError, fn ->
        Locales.get_locale!(ctx.locale.id)
      end
    end

    test "returns a locale changeset", ctx do
      assert %Ecto.Changeset{} = Locales.change_locale(ctx.locale)
    end
  end
end
