defmodule Runa.LanguagesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Runa.Languages` context.
  """

  alias Runa.Languages

  @default_attrs %{
    glotto_code: "some glotto_code",
    iso_code: "some iso_code",
    title: "some title",
    wals_code: "some wals_code"
  }

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
        wals_code: Atom.to_string(test)
      })
      |> Enum.into(@default_attrs)
      |> Languages.create_language()

    %{language: language}
  end

  def create_aux_language(attrs) do
    {:ok, language} =
      attrs
      |> Enum.into(@default_attrs)
      |> Languages.create_language()

    language
  end
end
