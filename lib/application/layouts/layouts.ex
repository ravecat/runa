defmodule RunaWeb.Layouts do
  use RunaWeb, :html

  import RunaWeb.Components.Sidebar

  embed_templates "/*"
end
