defmodule Runa.TranslationsTest do
  use Runa.DataCase, async: true

  @moduletag :translations

  alias Runa.Translations
  alias Runa.Translations.Translation

  setup do
    team = insert(:team)
    project = insert(:project, team: team)
    file = insert(:file, project: project)
    key = insert(:key, file: file)
    language = insert(:language)
    translation = insert(:translation, key: key, language: language)

    {:ok,
     translation: translation, key: key, project: project, language: language}
  end

  describe "translation context" do
    test "returns all entities" do
      {:ok, {data, %{}}} = Translations.index()

      Enum.each(data, &assert(is_struct(&1, Translation)))
    end

    test "returns the translation with given id", ctx do
      assert {:ok, translation} = Translations.get(ctx.translation.id)
      assert translation.id == ctx.translation.id
    end

    test "creates a translation with valid data", ctx do
      attrs = %{
        translation: Atom.to_string(ctx.test),
        key_id: ctx.key.id,
        language_id: ctx.language.id
      }

      assert {:ok, %Translation{} = translation} = Translations.create(attrs)

      assert translation.translation == Atom.to_string(ctx.test)
    end

    test "returns error changeset during creation with invalid data" do
      attrs = %{key_id: nil}

      assert {:error, %Ecto.Changeset{}} = Translations.create(attrs)
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
      attrs = %{translation: 11, key_id: ctx.key.id}

      assert {:error, %Ecto.Changeset{}} =
               Translations.update(ctx.translation, attrs)
    end

    test "deletes the translation", ctx do
      assert {:ok, %Translation{}} = Translations.delete(ctx.translation)

      assert {:error, %Ecto.NoResultsError{}} =
               Translations.get(ctx.translation.id)
    end

    test "returns a translation changeset", ctx do
      assert %Ecto.Changeset{} = Translations.change(ctx.translation)
    end
  end
end
