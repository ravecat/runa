defmodule Runa.TranslationsTest do
  @moduledoc false

  use Runa.DataCase

  @moduletag :translations

  alias Runa.{Translations, Translations.Translation}

  import Runa.Factory

  setup do
    team = insert(:team)
    project = insert(:project, team: team)
    key = insert(:key, project: project)
    translation = insert(:translation, key: key)

    {:ok, translation: translation, key: key, project: project}
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
      key = insert(:key, project: ctx.project)
      valid_attrs = %{translation: Atom.to_string(ctx.test), key_id: key.id}

      assert {:ok, %Translation{} = translation} =
               Translations.create_translation(valid_attrs)

      assert translation.translation == Atom.to_string(ctx.test)
    end

    test "returns error changeset during creation with invalid data" do
      invalid_attrs = %{key_id: nil}

      assert {:error, %Ecto.Changeset{}} =
               Translations.create_translation(invalid_attrs)
    end

    test "updates the translation with valid data", ctx do
      update_attrs = %{translation: Atom.to_string(ctx.test)}

      assert {:ok, %Translation{} = translation} =
               Translations.update_translation(ctx.translation, update_attrs)

      assert translation.translation == Atom.to_string(ctx.test)
    end

    test "returns error changeset during update with invalid data", ctx do
      key = insert(:key, project: ctx.project)
      invalid_attrs = %{translation: 11, key_id: key.id}

      assert {:error, %Ecto.Changeset{}} =
               Translations.update_translation(ctx.translation, invalid_attrs)
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
