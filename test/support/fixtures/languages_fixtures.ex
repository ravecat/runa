defmodule Runa.LanguagesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Runa.Languages` context.
  """

  @doc """
  Generate a language.
  """
  def create_aux_language(attrs \\ %{})

  def create_aux_language(%{test: test} = attrs) do
    {:ok, language} =
      attrs
      |> Enum.into(%{
        glotto_code: Atom.to_string(test),
        iso_code: Atom.to_string(test),
        title: Atom.to_string(test),
        walls_code: Atom.to_string(test)
      })
      |> Runa.Languages.create_language()

    %{language: language}
  end

  def create_aux_language(attrs) do
    {:ok, language} =
      attrs
      |> Enum.into(%{
        glotto_code: "some glotto_code",
        iso_code: "some iso_code",
        title: "some title",
        walls_code: "some walls_code"
      })
      |> Runa.Languages.create_language()

    language
  end
end
