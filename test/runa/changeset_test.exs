defmodule Runa.ChangesetTest do
  use ExUnit.Case, async: true

  import Ecto.Changeset
  import Runa.Changeset

  @types %{strings: {:array, :string}}
  @attrs %{strings: ["short", "optimal", "verylong"]}

  describe "validate_list/4" do
    test "with all valid elements" do
      changeset =
        {%{}, @types}
        |> cast(@attrs, [:strings])
        |> validate_list(:strings, fn changeset ->
          Ecto.Changeset.validate_length(changeset, :value, min: 1)
        end)

      assert changeset.valid?
      assert get_field(changeset, :strings) == @attrs[:strings]
      assert changeset.errors == []
    end

    test "with an invalid element" do
      changeset =
        {%{}, @types}
        |> cast(@attrs, [:strings])
        |> validate_list(:strings, fn changeset ->
          Ecto.Changeset.validate_length(changeset, :value, max: 7)
        end)

      refute changeset.valid?

      assert [
               strings:
                 {"verylong" <> _,
                  [count: 7, validation: :length, kind: :max, type: :string]}
             ] = changeset.errors
    end
  end

  test "with multiple invalid elements" do
    changeset =
      {%{}, @types}
      |> cast(@attrs, [:strings])
      |> validate_list(:strings, fn changeset ->
        Ecto.Changeset.validate_length(changeset, :value, min: 8)
      end)

    refute changeset.valid?

    assert [
             strings:
               {"short" <> _,
                [count: 8, validation: :length, kind: :min, type: :string]},
             strings:
               {"optimal" <> _,
                [count: 8, validation: :length, kind: :min, type: :string]}
           ] = changeset.errors
  end

  test "with an empty list" do
    changeset =
      {%{}, @types}
      |> cast(%{strings: []}, [:strings])
      |> validate_list(:strings, fn changeset ->
        Ecto.Changeset.validate_length(changeset, :value, max: 8)
      end)

    assert changeset.valid?
    assert changeset.errors == []
  end

  test "when field is not a list initially" do
    changeset =
      {%{}, @types}
      |> cast(%{strings: "not a list"}, [:strings])
      |> validate_list(:strings, fn changeset ->
        Ecto.Changeset.validate_length(changeset, :value, max: 8)
      end)

    refute changeset.valid?
    assert [strings: {"is invalid", _}] = changeset.errors
  end
end
