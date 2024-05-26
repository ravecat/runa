defmodule Runa.TranslationsTest do
  @moduledoc false

  use Runa.DataCase

  @moduletag :translations

  alias Runa.{Translations, Translations.Translation}

  import Runa.{
    TranslationsFixtures,
    KeysFixtures
  }

  setup do
    translation = create_aux_translation()

    %{translation: translation}
  end

  describe "translations" do
    test "returns all translations", ctx do
      assert Translations.list_translations() == [ctx.translation]
    end

    test "returns the translation with given id", ctx do
      assert Translations.get_translation!(ctx.translation.id) ==
               ctx.translation
    end

    test "creates a translation with valid data" do
      key = create_aux_key()
      valid_attrs = %{translation: "some translation", key_id: key.id}

      assert {:ok, %Translation{} = translation} =
               Translations.create_translation(valid_attrs)

      assert translation.translation == "some translation"
    end

    test "returns error changeset during creation with invalid data" do
      invalid_attrs = %{key_id: nil}

      assert {:error, %Ecto.Changeset{}} =
               Translations.create_translation(invalid_attrs)
    end

    test "updates the translation with valid data", ctx do
      update_attrs = %{translation: "some updated translation"}

      assert {:ok, %Translation{} = translation} =
               Translations.update_translation(ctx.translation, update_attrs)

      assert translation.translation == "some updated translation"
    end

    test "returns error changeset during update with invalid data", ctx do
      key = create_aux_key()
      invalid_attrs = %{translation: 11, key_id: key.id}

      assert {:error, %Ecto.Changeset{}} =
               Translations.update_translation(ctx.translation, invalid_attrs)

      assert ctx.translation ==
               Translations.get_translation!(ctx.translation.id)
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
