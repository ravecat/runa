defmodule Runa.LanguagesTest do
  @moduledoc false
  use Runa.DataCase

  @moduletag :languages

  alias Runa.Languages
  alias Runa.Languages.Language

  import Runa.LanguagesFixtures

  @invalid_attrs %{
    title: nil,
    wals_code: nil,
    iso_code: nil,
    glotto_code: nil
  }

  describe "languages" do
    setup [:create_aux_language]

    test "get_languages/0 returns all languages", ctx do
      assert Languages.get_languages() == [ctx.language]
    end

    test "get_language!/1 returns the language with given id", ctx do
      assert Languages.get_language!(ctx.language.id) == ctx.language
    end

    test "create_language/1 with valid data creates a language" do
      valid_attrs = %{
        title: "some title",
        wals_code: "some wals_code",
        iso_code: "some iso_code",
        glotto_code: "some glotto_code"
      }

      assert {:ok, %Language{} = language} =
               Languages.create_language(valid_attrs)

      assert language.title == "some title"
      assert language.wals_code == "some wals_code"
      assert language.iso_code == "some iso_code"
      assert language.glotto_code == "some glotto_code"
    end

    test "create_language/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Languages.create_language(@invalid_attrs)
    end

    test "update_language/2 with valid data updates the language", ctx do
      update_attrs = %{
        title: "some updated title",
        wals_code: "some updated wals_code",
        iso_code: "some updated iso_code",
        glotto_code: "some updated glotto_code"
      }

      assert {:ok, %Language{} = language} =
               Languages.update_language(ctx.language, update_attrs)

      assert language.title == "some updated title"
      assert language.wals_code == "some updated wals_code"
      assert language.iso_code == "some updated iso_code"
      assert language.glotto_code == "some updated glotto_code"
    end

    test "update_language/2 with invalid data returns error changeset", ctx do
      assert {:error, %Ecto.Changeset{}} =
               Languages.update_language(ctx.language, @invalid_attrs)

      assert ctx.language == Languages.get_language!(ctx.language.id)
    end

    test "delete_language/1 deletes the language", ctx do
      assert {:ok, %Language{}} = Languages.delete_language(ctx.language)

      assert_raise Ecto.NoResultsError, fn ->
        Languages.get_language!(ctx.language.id)
      end
    end

    test "change_language/1 returns a language changeset", ctx do
      assert %Ecto.Changeset{} = Languages.change_language(ctx.language)
    end
  end
end
