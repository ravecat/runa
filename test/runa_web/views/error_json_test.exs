defmodule RunaWeb.ErrorJSONTest do
  use RunaWeb.ConnCase, async: true

  @moduletag :json

  alias RunaWeb.ErrorJSON

  setup do
    conn = put_status(build_conn(), 409)

    {:ok, conn: conn}
  end

  test "renders 404" do
    assert ErrorJSON.render("404.json", %{}) == %{
             errors: [%{detail: "Not Found", status: "404", title: "Not Found"}]
           }
  end

  test "renders 500" do
    assert ErrorJSON.render("500.json", %{}) == %{
             errors: [
               %{
                 detail: "Internal Server Error",
                 status: "500",
                 title: "Internal Server Error"
               }
             ]
           }
  end

  test "renders changeset errors", ctx do
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

    assert ErrorJSON.error(%{changeset: changeset, conn: ctx.conn}) == %{
             errors: [
               %{
                 status: "409",
                 title: "description is too long",
                 source: %{pointer: "/data/attributes/description"}
               },
               %{
                 status: "409",
                 title: "title can't be blank",
                 source: %{pointer: "/data/attributes/title"}
               },
               %{
                 status: "409",
                 title: "title is too short",
                 source: %{pointer: "/data/attributes/title"}
               },
               %{
                 status: "409",
                 title: "member_count must be greater than 0",
                 source: %{pointer: "/data/attributes/member_count"}
               }
             ]
           }
  end
end
