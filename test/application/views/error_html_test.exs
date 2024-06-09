defmodule RunaWeb.ErrorHTMLTest do
  use RunaWeb.ConnCase

  # Bring render_to_string/4 for testing custom views
  import Phoenix.Template
  alias RunaWeb.{ErrorHTML, ErrorJSON}

  test "renders 404.html" do
    assert render_to_string(
             RunaWeb.ErrorHTML,
             "404",
             "html",
             []
           ) == "Not Found"
  end

  test "renders 500.html" do
    assert render_to_string(
             RunaWeb.ErrorHTML,
             "500",
             "html",
             []
           ) == "Internal Server Error"
  end
end
