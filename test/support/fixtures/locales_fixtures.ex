defmodule Runa.LocalesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Runa.Locales` context.
  """

  alias Runa.Locales

  @default_attrs %{}

  @doc """
  Generate a locale.
  """
  def create_aux_locales(attrs \\ %{})

  def create_aux_locales(%{test: _} = attrs) do
    {:ok, locale} =
      attrs
      |> Enum.into(%{
        project_id: attrs.project.id,
        language_id: attrs.language.id
      })
      |> Enum.into(@default_attrs)
      |> Locales.create_locale()

    %{locale: locale}
  end

  def create_aux_locales(attrs) do
    {:ok, locale} =
      attrs
      |> Enum.into(@default_attrs)
      |> Locales.create_locale()

    locale
  end
end
