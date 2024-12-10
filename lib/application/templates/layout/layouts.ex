defmodule RunaWeb.Layouts do
  use RunaWeb, :html

  import RunaWeb.Components.Flash

  embed_templates "/*"
end
