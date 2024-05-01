defmodule RunaWeb.Layouts do
  use RunaWeb, :html
  use RunaWeb, :widgets
  use RunaWeb, :components

  embed_templates "/*"
end
