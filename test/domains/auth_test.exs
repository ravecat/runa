defmodule Runa.AuthTest do
  @moduledoc false

  use RunaWeb.ConnCase, async: true

  @moduletag :auth

  alias Runa.Auth

  setup do
    insert(:role)

    auth = build(:auth)

    {:ok, auth: auth}
  end

  describe "authorization module" do
    test "handle full data", %{auth: auth} do
      assert {:ok, result} = Auth.find_or_create(auth)

      expected = %{
        uid: auth.uid,
        name: auth.info.name,
        avatar: auth.info.urls.avatar_url,
        nickname: auth.info.nickname,
        email: auth.info.email
      }

      assert Map.take(result, Map.keys(expected)) ==
               expected
    end

    test "handle data without avatar_url", %{auth: auth} do
      auth = %Ueberauth.Auth{
        uid: auth.uid,
        provider: auth.provider,
        info: %Ueberauth.Auth.Info{
          name: auth.info.name,
          image: auth.info.image,
          first_name: auth.info.first_name,
          last_name: auth.info.last_name,
          urls: %{
            avatar_url: nil
          },
          nickname: auth.info.nickname,
          email: auth.info.email
        }
      }

      expected = %{
        uid: auth.uid,
        name: auth.info.name,
        avatar: auth.info.image,
        nickname: auth.info.nickname,
        email: auth.info.email
      }

      assert {:ok, result} = Auth.find_or_create(auth)

      assert Map.take(result, Map.keys(expected)) ==
               expected
    end

    test "handle data without avatar_url, image", %{
      auth: auth
    } do
      auth = %Ueberauth.Auth{
        uid: auth.uid,
        provider: auth.provider,
        info: %Ueberauth.Auth.Info{
          name: auth.info.name,
          first_name: auth.info.first_name,
          last_name: auth.info.last_name,
          urls: %{
            avatar_url: nil
          },
          image: nil,
          nickname: auth.info.nickname,
          email: auth.info.email
        }
      }

      expected = %{
        uid: auth.uid,
        name: auth.info.name,
        avatar: nil,
        nickname: auth.info.nickname,
        email: auth.info.email
      }

      assert {:ok, result} = Auth.find_or_create(auth)

      assert Map.take(result, Map.keys(expected)) ==
               expected
    end

    test "handle data without name", %{auth: auth} do
      auth = %Ueberauth.Auth{
        uid: auth.uid,
        provider: auth.provider,
        info: %Ueberauth.Auth.Info{
          name: nil,
          image: auth.info.image,
          first_name: auth.info.first_name,
          last_name: auth.info.last_name,
          urls: %{
            avatar_url: auth.info.urls.avatar_url
          },
          nickname: auth.info.nickname,
          email: auth.info.email
        }
      }

      expected = %{
        uid: auth.uid,
        name: "#{auth.info.first_name} #{auth.info.last_name}",
        avatar: auth.info.urls.avatar_url,
        nickname: auth.info.nickname,
        email: auth.info.email
      }

      assert {:ok, result} = Auth.find_or_create(auth)

      assert Map.take(result, Map.keys(expected)) ==
               expected
    end

    test "handle data without name, first name", %{
      auth: auth
    } do
      auth = %Ueberauth.Auth{
        uid: auth.uid,
        provider: auth.provider,
        info: %Ueberauth.Auth.Info{
          name: nil,
          image: auth.info.image,
          first_name: nil,
          last_name: auth.info.last_name,
          urls: %{
            avatar_url: auth.info.urls.avatar_url
          },
          nickname: auth.info.nickname,
          email: auth.info.email
        }
      }

      expected = %{
        uid: auth.uid,
        name: auth.info.last_name,
        avatar: auth.info.urls.avatar_url,
        nickname: auth.info.nickname,
        email: auth.info.email
      }

      assert {:ok, result} = Auth.find_or_create(auth)

      assert Map.take(result, Map.keys(expected)) ==
               expected
    end

    test "handles data without name, last name", %{
      auth: auth
    } do
      auth = %Ueberauth.Auth{
        uid: auth.uid,
        provider: auth.provider,
        info: %Ueberauth.Auth.Info{
          name: nil,
          image: auth.info.image,
          first_name: auth.info.first_name,
          last_name: nil,
          urls: %{
            avatar_url: auth.info.urls.avatar_url
          },
          nickname: auth.info.nickname,
          email: auth.info.email
        }
      }

      expected = %{
        uid: auth.uid,
        name: auth.info.first_name,
        avatar: auth.info.urls.avatar_url,
        nickname: auth.info.nickname,
        email: auth.info.email
      }

      assert {:ok, result} = Auth.find_or_create(auth)

      assert Map.take(result, Map.keys(expected)) ==
               expected
    end

    test "handle data without name, first name, last name",
         %{auth: auth} do
      auth = %Ueberauth.Auth{
        uid: auth.uid,
        provider: auth.provider,
        info: %Ueberauth.Auth.Info{
          name: nil,
          image: auth.info.image,
          first_name: nil,
          last_name: nil,
          urls: %{
            avatar_url: auth.info.urls.avatar_url
          },
          nickname: auth.info.nickname,
          email: auth.info.email
        }
      }

      expected = %{
        uid: auth.uid,
        name: auth.info.nickname,
        avatar: auth.info.urls.avatar_url,
        nickname: auth.info.nickname,
        email: auth.info.email
      }

      assert {:ok, result} = Auth.find_or_create(auth)

      assert Map.take(result, Map.keys(expected)) ==
               expected
    end

    test "handle data without name, first name, last name, nickname",
         %{auth: auth} do
      auth = %Ueberauth.Auth{
        uid: auth.uid,
        provider: auth.provider,
        info: %Ueberauth.Auth.Info{
          name: nil,
          image: auth.info.image,
          first_name: nil,
          last_name: nil,
          urls: %{
            avatar_url: auth.info.urls.avatar_url
          },
          nickname: nil,
          email: auth.info.email
        }
      }

      expected = %{
        uid: auth.uid,
        name: auth.info.email,
        avatar: auth.info.urls.avatar_url,
        nickname: auth.info.nickname,
        email: auth.info.email
      }

      assert {:ok, result} = Auth.find_or_create(auth)

      assert Map.take(result, Map.keys(expected)) ==
               expected
    end

    test "returns error for data without uid", %{auth: auth} do
      auth = %Ueberauth.Auth{
        provider: auth.provider,
        info: %Ueberauth.Auth.Info{
          name: auth.info.name,
          image: auth.info.image,
          first_name: auth.info.first_name,
          last_name: auth.info.last_name,
          urls: %{
            avatar_url: auth.info.urls.avatar_url
          },
          nickname: auth.info.nickname,
          email: auth.info.email
        }
      }

      assert {:error, %Ecto.Changeset{}} = Auth.find_or_create(auth)
    end

    test "returns error for data without email", %{auth: auth} do
      auth = %Ueberauth.Auth{
        uid: auth.uid,
        provider: auth.provider,
        info: %Ueberauth.Auth.Info{
          name: auth.info.name,
          image: auth.info.image,
          first_name: auth.info.first_name,
          last_name: auth.info.last_name,
          urls: %{
            avatar_url: auth.info.urls.avatar_url
          },
          nickname: auth.info.nickname
        }
      }

      assert {:error, %Ecto.Changeset{}} = Auth.find_or_create(auth)
    end

    test "handle data without nickname", %{auth: auth} do
      auth = %Ueberauth.Auth{
        uid: auth.uid,
        provider: auth.provider,
        info: %Ueberauth.Auth.Info{
          name: auth.info.name,
          image: auth.info.image,
          first_name: auth.info.first_name,
          last_name: auth.info.last_name,
          urls: %{
            avatar_url: auth.info.urls.avatar_url
          },
          nickname: nil,
          email: auth.info.email
        }
      }

      expected = %{
        uid: auth.uid,
        name: auth.info.name,
        avatar: auth.info.urls.avatar_url,
        nickname: nil,
        email: auth.info.email
      }

      assert {:ok, result} = Auth.find_or_create(auth)

      assert Map.take(result, Map.keys(expected)) ==
               expected
    end
  end
end
