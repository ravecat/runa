defmodule Runa.TranslationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Runa.Translations` context.
  """

  alias Runa.Translations

  @default_attrs %{
    translation: "Hello, World!"
  }

  @doc """
  Generate a translation.
  """
  def create_aux_translation(attrs \\ %{})

  def create_aux_translation(%{test: _test} = attrs) do
    {:ok, translation} =
      attrs
      |> Enum.into(@default_attrs)
      |> Enum.into(%{key_id: attrs.key.id})
      |> Translations.create_translation()

    %{translation: translation}
  end

  def create_aux_translation(attrs) do
    {:ok, translation} =
      attrs
      |> Enum.into(@default_attrs)
      |> Translations.create_translation()

    translation
  end
end
