defmodule Runa.TranslationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Runa.Translations` context.
  """

  alias Runa.Translations

  import Runa.KeysFixtures

  @doc """
  Generate a translation.
  """

  def create_aux_translation(attrs \\ %{}) do
    key = create_aux_key()

    default_attrs = %{
      translation: "Hello, World!",
      key_id: key.id
    }

    {:ok, translation} =
      attrs
      |> Enum.into(default_attrs)
      |> Translations.create_translation()

    translation
  end
end
