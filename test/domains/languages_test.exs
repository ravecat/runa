defmodule Runa.LanguagesTest do
  @moduledoc false

  use Runa.DataCase

  @moduletag :languages

  alias Runa.{Languages.Language, Languages}

  import Runa.LanguagesFixtures

  setup tags do
    language =
      create_aux_language(%{
        title: Atom.to_string(tags.test),
        wals_code: Atom.to_string(tags.test),
        iso_code: Atom.to_string(tags.test),
        glotto_code: Atom.to_string(tags.test)
      })

    %{language: language}
  end

  describe "languages" do
    test "returns all languages", ctx do
      assert Languages.get_languages() == [ctx.language]
    end

    test "returns the language with given id", ctx do
      assert Languages.get_language!(ctx.language.id) == ctx.language
    end

    test "creates a language with valid data" do
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

    test "returns error changeset during creation with invalid data" do
      invalid_attrs = %{
        title: nil,
        wals_code: nil,
        iso_code: nil,
        glotto_code: nil
      }

      assert {:error, %Ecto.Changeset{}} =
               Languages.create_language(invalid_attrs)
    end

    test "updates the language with valid data", ctx do
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

    test "returns error changeset during update with invalid data", ctx do
      invalid_attrs = %{
        title: nil,
        wals_code: nil,
        iso_code: nil,
        glotto_code: nil
      }

      assert {:error, %Ecto.Changeset{}} =
               Languages.update_language(ctx.language, invalid_attrs)

      assert ctx.language == Languages.get_language!(ctx.language.id)
    end

    test "deletes the language", ctx do
      assert {:ok, %Language{}} = Languages.delete_language(ctx.language)

      assert_raise Ecto.NoResultsError, fn ->
        Languages.get_language!(ctx.language.id)
      end
    end

    test "returns a language changeset", ctx do
      assert %Ecto.Changeset{} = Languages.change_language(ctx.language)
    end
  end
end
