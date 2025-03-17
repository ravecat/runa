defmodule Runa.LanguagesTest do
  @moduledoc false

  use Runa.DataCase

  @moduletag :languages

  alias Runa.Languages
  alias Runa.Languages.Language

  setup do
    language = insert(:language)

    {:ok, language: language}
  end

  describe "languages" do
    test "returns all languages", ctx do
      assert {:ok, {[ctx.language], %{}}} == Languages.index()
    end

    test "returns the language with given id", ctx do
      assert {:ok, ctx.language} == Languages.get(ctx.language.id)
    end

    test "creates a language with valid data", ctx do
      valid_attrs = %{
        title: Atom.to_string(ctx.test),
        wals_code: Atom.to_string(ctx.test),
        iso_code: Atom.to_string(ctx.test),
        glotto_code: Atom.to_string(ctx.test)
      }

      assert {:ok, %Language{} = language} = Languages.create(valid_attrs)

      assert language.title == Atom.to_string(ctx.test)
      assert language.wals_code == Atom.to_string(ctx.test)
      assert language.iso_code == Atom.to_string(ctx.test)
      assert language.glotto_code == Atom.to_string(ctx.test)
    end

    test "returns error changeset during creation with invalid data" do
      invalid_attrs = %{
        title: nil,
        wals_code: nil,
        iso_code: nil,
        glotto_code: nil
      }

      assert {:error, %Ecto.Changeset{}} = Languages.create(invalid_attrs)
    end

    test "updates the language with valid data", ctx do
      update_attrs = %{
        title: Atom.to_string(ctx.test),
        wals_code: Atom.to_string(ctx.test),
        iso_code: Atom.to_string(ctx.test),
        glotto_code: Atom.to_string(ctx.test)
      }

      assert {:ok, %Language{} = language} =
               Languages.update(ctx.language, update_attrs)

      assert language.id == ctx.language.id
      assert language.title == Atom.to_string(ctx.test)
      assert language.wals_code == Atom.to_string(ctx.test)
      assert language.iso_code == Atom.to_string(ctx.test)
      assert language.glotto_code == Atom.to_string(ctx.test)
    end

    test "returns error changeset during update with invalid data", ctx do
      invalid_attrs = %{
        title: nil,
        wals_code: nil,
        iso_code: nil,
        glotto_code: nil
      }

      assert {:error, %Ecto.Changeset{}} =
               Languages.update(ctx.language, invalid_attrs)

      assert {:ok, ctx.language} == Languages.get(ctx.language.id)
    end

    test "deletes the language", ctx do
      assert {:ok, %Language{}} = Languages.delete(ctx.language)

      assert {:error, %Ecto.NoResultsError{}} = Languages.get(ctx.language.id)
    end

    test "returns a language changeset", ctx do
      assert %Ecto.Changeset{} = Languages.change(ctx.language)
    end
  end
end
