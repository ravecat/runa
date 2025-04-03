defmodule RunaWeb.Adapters.FormTest do
  @moduledoc false

  use ExUnit.Case, async: true

  defmodule User do
    @derive Jason.Encoder
    @enforce_keys [:name, :email]

    defstruct [:name, :email]
  end

  describe "Phoenix.HTML.Form to Svelte superforms compatible JSON adapter" do
    test "encodes a form with data and simple string errors" do
      form = %Phoenix.HTML.Form{
        id: "user",
        name: "user",
        data: %User{name: "test", email: "test@example.com"},
        errors: [name: "can't be blank"]
      }

      assert Jason.encode!(form) |> Jason.decode!() == %{
               "data" => %{"email" => "test@example.com", "name" => "test"},
               "errors" => %{"name" => ["can't be blank"]},
               "id" => "user",
               "name" => "user",
               "posted" => true,
               "valid" => false
             }
    end

    test "encodes a form with simple string errors" do
      form = %Phoenix.HTML.Form{
        id: "user",
        name: "user",
        data: %User{name: "test", email: "test@example.com"},
        errors: [name: "can't be blank", email: "is invalid"]
      }

      assert Jason.encode!(form) |> Jason.decode!() == %{
               "data" => %{"email" => "test@example.com", "name" => "test"},
               "errors" => %{
                 "name" => ["can't be blank"],
                 "email" => ["is invalid"]
               },
               "id" => "user",
               "name" => "user",
               "posted" => true,
               "valid" => false
             }
    end

    test "encodes a form with errors as tuples with options" do
      form = %Phoenix.HTML.Form{
        id: "user",
        name: "user",
        data: %User{name: "test", email: "test@example.com"},
        errors: [
          name: {"Can't be blank", [validation: :required]},
          email: {"Can't be blank", [validation: :required]}
        ]
      }

      assert Jason.encode!(form) |> Jason.decode!() == %{
               "data" => %{"email" => "test@example.com", "name" => "test"},
               "errors" => %{
                 "name" => ["Can't be blank"],
                 "email" => ["Can't be blank"]
               },
               "id" => "user",
               "name" => "user",
               "posted" => true,
               "valid" => false
             }
    end

    test "encodes a form with errors as tuples with validation options" do
      form = %Phoenix.HTML.Form{
        id: "user",
        name: "user",
        data: %User{name: "test", email: "test@example.com"},
        errors: [
          name:
            {"should be at least %{count} character(s)",
             [count: 2, validation: :length, kind: :min, type: :string]}
        ]
      }

      assert Jason.encode!(form) |> Jason.decode!() == %{
               "data" => %{"email" => "test@example.com", "name" => "test"},
               "errors" => %{"name" => ["should be at least 2 character(s)"]},
               "id" => "user",
               "name" => "user",
               "posted" => true,
               "valid" => false
             }
    end
  end
end
