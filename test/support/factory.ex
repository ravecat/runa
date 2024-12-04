defmodule Runa.Factory do
  @moduledoc """
  Factory module for generating test data.
  """
  use ExMachina.Ecto, repo: Runa.Repo

  alias Runa.Accounts.User
  alias Runa.Contributors.Contributor
  alias Runa.Files.File
  alias Runa.Keys.Key
  alias Runa.Languages.Language
  alias Runa.Languages.Locale
  alias Runa.Projects.Project
  alias Runa.Teams.Team
  alias Runa.Tokens
  alias Runa.Tokens.Token
  alias Runa.Translations.Translation

  def team_factory(attrs) do
    %Team{
      title: Faker.Company.buzzword_prefix()
    }
    |> merge_attributes(attrs)
    |> evaluate_lazy_attributes()
  end

  def project_factory(attrs) do
    %Project{
      name: sequence(:title, &"project title #{&1}"),
      description: sequence(:description, &"project description #{&1}")
    }
    |> merge_attributes(attrs)
    |> evaluate_lazy_attributes()
  end

  def user_factory(attrs) do
    %User{
      email: Faker.Internet.email(),
      uid: Faker.UUID.v4(),
      name: Faker.Person.name(),
      nickname: Faker.Pokemon.name(),
      avatar: Faker.Avatar.image_url(),
      contributors: fn ->
        build_list(1, :contributor, team: fn -> build(:team) end)
      end,
      tokens: fn ->
        build_list(3, :token)
      end
    }
    |> merge_attributes(attrs)
    |> evaluate_lazy_attributes()
  end

  def contributor_factory(attrs) do
    %Contributor{
      role: sequence(:role, [:owner, :admin, :editor, :viewer])
    }
    |> merge_attributes(attrs)
    |> evaluate_lazy_attributes()
  end

  def token_factory(attrs) do
    token = attrs[:token] || Tokens.generate()
    hash = Tokens.hash(token)

    %Token{
      hash: hash,
      token: token,
      access: sequence(:access, [:read, :write, :suspended]),
      title: Faker.Pokemon.name()
    }
    |> merge_attributes(attrs)
    |> evaluate_lazy_attributes()
  end

  def language_factory(attrs) do
    %Language{
      glotto_code: sequence(:wals_code, &"glotto_code_#{&1}"),
      iso_code: sequence(:wals_code, &"iso_code_#{&1}"),
      title: "title",
      wals_code: sequence(:wals_code, &"wals_code_#{&1}")
    }
    |> merge_attributes(attrs)
    |> evaluate_lazy_attributes()
  end

  def locale_factory(attrs) do
    %Locale{}
    |> merge_attributes(attrs)
    |> evaluate_lazy_attributes()
  end

  def translation_factory(attrs) do
    %Translation{
      translation: sequence(:translation, &"translation #{&1}")
    }
    |> merge_attributes(attrs)
    |> evaluate_lazy_attributes()
  end

  def key_factory(attrs) do
    %Key{
      name: sequence(:name, &"key name #{&1}"),
      description: sequence(:description, &"key description #{&1}")
    }
    |> merge_attributes(attrs)
    |> evaluate_lazy_attributes()
  end

  def file_factory(attrs) do
    %File{
      filename: sequence(:filename, &"filename #{&1}")
    }
    |> merge_attributes(attrs)
    |> evaluate_lazy_attributes()
  end
end
