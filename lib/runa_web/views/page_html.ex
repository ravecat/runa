defmodule RunaWeb.PageHTML do
  use RunaWeb, :html

  import RunaWeb.Components.Icon

  embed_templates "../templates/page/*"
end
