defmodule RunaWeb.PageHTML do
  use RunaWeb, :html
  use RunaWeb, :components

  embed_templates "../templates/page/*"
end
