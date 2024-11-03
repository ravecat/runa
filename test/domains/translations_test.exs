defmodule Runa.TranslationsTest do
  @moduledoc false

  use Runa.DataCase

  @moduletag :translations

  alias Runa.Translations
  alias Runa.Translations.Translation

  setup do
    team = insert(:team)
    project = insert(:project, team: team)
    key = insert(:key, project: project)
    translation = insert(:translation, key: key)
    language = insert(:language)

    {:ok,
     translation: translation, key: key, project: project, language: language}
  end

  describe "translations" do
    test "returns all translations", ctx do
      assert [translation] = Translations.list_translations()
      assert ctx.translation.id == translation.id
    end

    test "returns the translation with given id", ctx do
      assert translation = Translations.get_translation!(ctx.translation.id)
      assert translation.id == ctx.translation.id
    end

    test "creates a translation with valid data", ctx do
      attrs = %{
        translation: Atom.to_string(ctx.test),
        key_id: ctx.key.id,
        language_id: ctx.language.id
      }

      assert {:ok, %Translation{} = translation} =
               Translations.create(attrs)

      assert translation.translation == Atom.to_string(ctx.test)
    end

    test "returns error changeset during creation with invalid data" do
      invalid_attrs = %{key_id: nil}

      assert {:error, %Ecto.Changeset{}} =
               Translations.create(invalid_attrs)
    end

    test "updates the translation with valid data", ctx do
      attrs = %{
        translation: Atom.to_string(ctx.test),
        language_id: ctx.language.id,
        key_id: ctx.key.id
      }

      assert {:ok, %Translation{} = translation} =
               Translations.update(ctx.translation, attrs)

      assert translation.translation == Atom.to_string(ctx.test)
    end

    test "returns error changeset during update with invalid data", ctx do
      key = insert(:key, project: ctx.project)
      invalid_attrs = %{translation: 11, key_id: key.id}

      assert {:error, %Ecto.Changeset{}} =
               Translations.update(ctx.translation, invalid_attrs)
    end

    test "deletes the translation", ctx do
      assert {:ok, %Translation{}} =
               Translations.delete_translation(ctx.translation)

      assert_raise Ecto.NoResultsError, fn ->
        Translations.get_translation!(ctx.translation.id)
      end
    end

    test "returns a translation changeset", ctx do
      assert %Ecto.Changeset{} =
               Translations.change_translation(ctx.translation)
    end
  end
end
