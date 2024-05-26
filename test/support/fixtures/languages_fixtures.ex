defmodule Runa.LanguagesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Runa.Languages` context.
  """

  alias Runa.Languages

  @doc """
  Generate a language.
  """
  def create_aux_language(attrs \\ %{}) do
    {:ok, language} =
      attrs
      |> Enum.into(%{
        glotto_code: "some glotto_code",
        iso_code: "some iso_code",
        title: "some title",
        wals_code: "some wals_code"
      })
      |> Languages.create_language()

    language
  end
end
