defmodule RunaWeb.Adapters.Error do
  @moduledoc """
  Error adapter for errors in forms, changesets, etc.

  This module provides functions to translate error messages with Gettext.
  """
  def translate_error({msg, opts}) do
    Gettext.dgettext(RunaWeb.Gettext, "errors", msg, opts)
  end

  def translate_error(msg) when is_binary(msg) do
    Gettext.dgettext(RunaWeb.Gettext, "errors", msg)
  end
end
