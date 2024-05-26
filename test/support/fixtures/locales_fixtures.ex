defmodule Runa.LocalesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Runa.Locales` context.
  """

  alias Runa.Locales

  import Runa.{ProjectsFixtures, LanguagesFixtures}

  @doc """
  Generate a locale.
  """
  def create_aux_locale(attrs \\ %{}) do
    project = create_aux_project()
    language = create_aux_language()

    default_attrs = %{
      project_id: project.id,
      language_id: language.id
    }

    {:ok, locale} =
      attrs
      |> Enum.into(default_attrs)
      |> Locales.create_locale()

    locale
  end
end
