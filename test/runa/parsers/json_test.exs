defmodule Runa.Parsers.JSONTest do
  use ExUnit.Case

  alias Runa.Parsers.JSON

  setup do
    {:ok, agent} = Agent.start_link(fn -> [] end)

    {:ok, agent: agent}
  end

  describe "JSON parser" do
    test "parses JSON V1 correctly" do
      json_path = "test/fixtures/json/v1.json"

      {:ok, results} = JSON.parse(json_path)

      expected = [
        {"key", "value"},
        {"keyDeep.inner", "value"},
        {"keyNesting", "reuse $t(keyDeep.inner)"},
        {"keyInterpolate", "replace this __value__"},
        {"keyInterpolateUnescaped", "replace this __valueHTML__"},
        {"keyContext_male", "the male variant"},
        {"keyContext_female", "the female variant"},
        {"keyPluralSimple", "the singular"},
        {"keyPluralSimple_plural", "the plural"},
        {"keyPluralMultipleEgArabic", "the plural form 0"},
        {"keyPluralMultipleEgArabic_plural_1", "the plural form 1"},
        {"keyPluralMultipleEgArabic_plural_2", "the plural form 2"},
        {"keyPluralMultipleEgArabic_plural_3", "the plural form 3"},
        {"keyPluralMultipleEgArabic_plural_11", "the plural form 4"},
        {"keyPluralMultipleEgArabic_plural_100", "the plural form 5"}
      ]

      assert results == expected
    end

    test "parses JSON V2 correctly" do
      json_path = "test/fixtures/json/v2.json"

      {:ok, results} = JSON.parse(json_path)

      expected = [
        {"key", "value"},
        {"keyDeep.inner", "value"},
        {"keyNesting", "reuse $t(keyDeep.inner)"},
        {"keyInterpolate", "replace this {{value}}"},
        {"keyInterpolateUnescaped", "replace this {{- value}}"},
        {"keyContext_male", "the male variant"},
        {"keyContext_female", "the female variant"},
        {"keyPluralSimple", "the singular"},
        {"keyPluralSimple_plural", "the plural"},
        {"keyPluralMultipleEgArabic_0", "the plural form 0"},
        {"keyPluralMultipleEgArabic_1", "the plural form 1"},
        {"keyPluralMultipleEgArabic_2", "the plural form 2"},
        {"keyPluralMultipleEgArabic_3", "the plural form 3"},
        {"keyPluralMultipleEgArabic_11", "the plural form 4"},
        {"keyPluralMultipleEgArabic_100", "the plural form 5"}
      ]

      assert results == expected
    end

    test "parses JSON V3 correctly" do
      json_path = "test/fixtures/json/v3.json"

      {:ok, results} = JSON.parse(json_path)

      expected = [
        {"key", "value"},
        {"keyDeep.inner", "value"},
        {"keyNesting", "reuse $t(keyDeep.inner)"},
        {"keyInterpolate", "replace this {{value}}"},
        {"keyInterpolateUnescaped", "replace this {{- value}}"},
        {"keyInterpolateWithFormatting", "replace this {{value, format}}"},
        {"keyContext_male", "the male variant"},
        {"keyContext_female", "the female variant"},
        {"keyPluralSimple", "the singular"},
        {"keyPluralSimple_plural", "the plural"},
        {"keyPluralMultipleEgArabic_0", "the plural form 0"},
        {"keyPluralMultipleEgArabic_1", "the plural form 1"},
        {"keyPluralMultipleEgArabic_2", "the plural form 2"},
        {"keyPluralMultipleEgArabic_3", "the plural form 3"},
        {"keyPluralMultipleEgArabic_4", "the plural form 4"},
        {"keyPluralMultipleEgArabic_5", "the plural form 5"},
        {"keyWithObjectValue.valueA", "return this with valueB"},
        {"keyWithObjectValue.valueB", "more text"}
      ]

      assert results == expected
    end

    test "parses JSON V4 correctly" do
      json_path = "test/fixtures/json/v4.json"

      {:ok, results} = JSON.parse(json_path)

      expected = [
        {"key", "value"},
        {"keyDeep.inner", "value"},
        {"keyNesting", "reuse $t(keyDeep.inner)"},
        {"keyInterpolate", "replace this {{value}}"},
        {"keyInterpolateUnescaped", "replace this {{- value}}"},
        {"keyInterpolateWithFormatting", "replace this {{value, format}}"},
        {"keyContext_male", "the male variant"},
        {"keyContext_female", "the female variant"},
        {"keyPluralSimple_one", "the singular"},
        {"keyPluralSimple_other", "the plural"},
        {"keyPluralMultipleEgArabic_zero", "the plural form 0"},
        {"keyPluralMultipleEgArabic_one", "the plural form 1"},
        {"keyPluralMultipleEgArabic_two", "the plural form 2"},
        {"keyPluralMultipleEgArabic_few", "the plural form 3"},
        {"keyPluralMultipleEgArabic_many", "the plural form 4"},
        {"keyPluralMultipleEgArabic_other", "the plural form 5"},
        {"keyWithObjectValue.valueA", "return this with valueB"},
        {"keyWithObjectValue.valueB", "more text"}
      ]

      assert results == expected
    end
  end
end
