defmodule Runa.Factory do
  @moduledoc """
  Factory module for generating test data.
  """
  use ExMachina.Ecto, repo: Runa.Repo

  alias Runa.Accounts.User
  alias Runa.Contributors.Contributor
  alias Runa.Files.File
  alias Runa.Invitations.Invitation
  alias Runa.Keys.Key
  alias Runa.Languages.Language
  alias Runa.Languages.Locale
  alias Runa.Projects.Project
  alias Runa.Services.Avatar
  alias Runa.Teams.Team
  alias Runa.Tokens
  alias Runa.Tokens.Token
  alias Runa.Translations.Translation

  def team_factory(attrs) do
    %Team{title: Faker.Company.buzzword_prefix()}
    |> merge_attributes(attrs)
    |> evaluate_lazy_attributes()
  end

  def project_factory(attrs) do
    %Project{name: Faker.Pokemon.name(), description: Faker.StarWars.quote()}
    |> merge_attributes(attrs)
    |> evaluate_lazy_attributes()
  end

  def user_factory(attrs) do
    %User{
      email: Faker.Internet.email(),
      uid: Faker.UUID.v4(),
      name: Faker.Person.name(),
      nickname: Faker.Pokemon.name(),
      avatar: Avatar.generate_url(Faker.Pokemon.name(), style: :thumbs)
    }
    |> merge_attributes(attrs)
    |> evaluate_lazy_attributes()
  end

  def contributor_factory(attrs) do
    %Contributor{role: sequence(:role, [:admin, :editor, :viewer])}
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
    %Translation{translation: Faker.Lorem.sentence()}
    |> merge_attributes(attrs)
    |> evaluate_lazy_attributes()
  end

  def key_factory(attrs) do
    %Key{name: Faker.Lorem.sentence(), description: Faker.Lorem.sentence()}
    |> merge_attributes(attrs)
    |> evaluate_lazy_attributes()
  end

  def file_factory(attrs) do
    %File{filename: "#{Faker.File.file_name(:text)}"}
    |> merge_attributes(attrs)
    |> evaluate_lazy_attributes()
  end

  def invitation_factory(attrs) do
    %Invitation{
      token: :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false),
      status: :pending,
      expires_at: DateTime.add(DateTime.utc_now(), 86400),
      email: Faker.Internet.email(),
      role: sequence(:role, [:admin, :editor, :viewer])
    }
    |> merge_attributes(attrs)
    |> evaluate_lazy_attributes()
  end
end
