defmodule Runa.LocalesTest do
  @moduledoc false

  use Runa.DataCase

  @moduletag :locales

  alias Runa.Locales
  alias Runa.Locales.Locale

  setup do
    team = insert(:team)
    project = insert(:project, team: team)
    language = insert(:language)

    locale = insert(:locale, project: project, language: language)

    {:ok, locale: locale, team: team}
  end

  describe "locale context" do
    test "returns all entities", ctx do
      assert {:ok, {[locale], %{}}} = Locales.index()
      assert ctx.locale.id == locale.id
      assert locale.project_id == ctx.locale.project_id
      assert locale.language_id == ctx.locale.language_id
    end

    test "returns entity with given id", ctx do
      assert {:ok, locale} = Locales.get(ctx.locale.id)
      assert ctx.locale.id == locale.id
      assert locale.project_id == ctx.locale.project_id
      assert locale.language_id == ctx.locale.language_id
    end

    test "creates enitity with valid data", ctx do
      project = insert(:project, team: ctx.team)
      language = insert(:language, wals_code: Atom.to_string(ctx.test))

      valid_attrs = %{project_id: project.id, language_id: language.id}

      assert {:ok, %Locale{}} = Locales.create(valid_attrs)
    end

    test "returns error changeset during creation with invalid data" do
      invalid_attrs = %{}

      assert {:error, %Ecto.Changeset{}} = Locales.create(invalid_attrs)
    end

    test "updates entity with valid data", ctx do
      project = insert(:project, team: ctx.team)

      update_attrs = %{
        project_id: project.id
      }

      assert {:ok, %Locale{} = locale} =
               Locales.update(ctx.locale, update_attrs)

      assert locale.project_id == project.id
    end

    test "returns error changeset during update with invalid data", ctx do
      invalid_attrs = %{project_id: nil, language_id: nil}

      assert {:error, %Ecto.Changeset{}} =
               Locales.update(ctx.locale, invalid_attrs)
    end

    test "deletes entity", ctx do
      assert {:ok, %Locale{}} = Locales.delete(ctx.locale)

      assert {:error, %Ecto.NoResultsError{}} = Locales.get(ctx.locale.id)
    end

    test "returns entity changeset", ctx do
      assert %Ecto.Changeset{} = Locales.change(ctx.locale)
    end
  end
end
