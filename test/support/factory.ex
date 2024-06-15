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
  alias Runa.Locales.Locale
  alias Runa.Projects.Project
  alias Runa.Roles.Role
  alias Runa.Teams.Team
  alias Runa.Tokens.Token
  alias Runa.Translations.Translation

  @roles Application.compile_env(:runa, :permissions)
  @valid_access_levels Application.compile_env(:runa, :token_access_levels)

  def team_factory(attrs) do
    %Team{
      title: sequence(:title, &"team title #{&1}")
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

  def role_factory(attrs) do
    %Role{
      title: @roles[:owner]
    }
    |> merge_attributes(attrs)
    |> evaluate_lazy_attributes()
  end

  def user_factory(attrs) do
    %User{
      email: sequence(:email, &"user#{&1}@example.com"),
      uid: sequence(:uid, &"uid#{&1}"),
      name: sequence(:name, &"user name #{&1}"),
      avatar: sequence(:avatar, &"https://img.example.com/#{&1}.png"),
      nickname: sequence(:nickname, &"nickname #{&1}")
    }
    |> merge_attributes(attrs)
    |> evaluate_lazy_attributes()
  end

  def contributor_factory(attrs) do
    %Contributor{}
    |> merge_attributes(attrs)
    |> evaluate_lazy_attributes()
  end

  def token_factory(attrs) do
    %Token{
      token: sequence(:token, &"token#{&1}"),
      access: sequence(:access, Map.values(@valid_access_levels))
    }
    |> merge_attributes(attrs)
    |> evaluate_lazy_attributes()
  end

  def auth_factory(attrs) do
    %Ueberauth.Auth{
      uid: sequence(:uid, &"auth#{&1}"),
      provider: :auth0,
      info: %Ueberauth.Auth.Info{
        name: "John Doe",
        email: "john@mail.com",
        first_name: "John",
        last_name: "Doe",
        urls: %{avatar_url: "https://example.com/image.jpg"},
        nickname: "johndoe",
        image: "https://example.com/image.jpg"
      }
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
