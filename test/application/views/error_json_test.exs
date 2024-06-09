defmodule RunaWeb.ErrorJSONTest do
  @moduledoc false
  use RunaWeb.ConnCase

  @moduletag :json

  alias RunaWeb.ErrorJSON

  test "renders 404" do
    assert ErrorJSON.render("404.json", %{}) == %{
             errors: [%{detail: "Not Found", code: "404", title: "Not Found"}]
           }
  end

  test "renders 500" do
    assert ErrorJSON.render("500.json", %{}) ==
             %{
               errors: [
                 %{
                   detail: "Internal Server Error",
                   code: "500",
                   title: "Internal Server Error"
                 }
               ]
             }
  end

  test "renders changeset errors" do
    changeset = %Ecto.Changeset{
      types: %{},
      errors: [
        title: {"can't be blank", [validation: :required]},
        title: {"is too short", [validation: :length, min: 2]},
        description: {"is too long", [validation: :length, max: 500]},
        member_count:
          {"must be greater than 0", [validation: :number, greater_than: 0]}
      ]
    }

    assert ErrorJSON.error(%{changeset: changeset}) == %{
             errors: [
               %{
                 title: "description is too long",
                 source: %{pointer: "/data/attributes/description"}
               },
               %{
                 title: "title can't be blank",
                 source: %{pointer: "/data/attributes/title"}
               },
               %{
                 title: "title is too short",
                 source: %{pointer: "/data/attributes/title"}
               },
               %{
                 title: "member_count must be greater than 0",
                 source: %{pointer: "/data/attributes/member_count"}
               }
             ]
           }
  end
end
