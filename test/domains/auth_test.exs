defmodule Runa.Auth.Test do
  use RunaWeb.ConnCase

  import Runa.Auth.Fixtures
  import Runa.Accounts.Fixtures

  alias Runa.Accounts
  alias Ueberauth.Auth

  describe "authorization module for auth0 provider" do
    setup [:create_aux_success_auth, :create_aux_user]

    test "handle full data", %{auth: auth} do
      assert Runa.Auth.find_or_create(auth) ==
               {:ok,
                %{
                  uid: auth.uid,
                  name: auth.info.name,
                  avatar: auth.info.urls.avatar_url,
                  nickname: auth.info.nickname,
                  email: auth.info.email
                }}
    end

    test "handle data without avatar_url", %{auth: auth} do
      auth = %Auth{
        uid: auth.uid,
        provider: auth.provider,
        info: %Auth.Info{
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

      assert Runa.Auth.find_or_create(auth) ==
               {:ok,
                %{
                  uid: auth.uid,
                  name: auth.info.name,
                  avatar: auth.info.image,
                  nickname: auth.info.nickname,
                  email: auth.info.email
                }}
    end

    test "handle data without avatar_url, image", %{auth: auth} do
      auth = %Auth{
        uid: auth.uid,
        provider: auth.provider,
        info: %Auth.Info{
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

      assert Runa.Auth.find_or_create(auth) ==
               {:ok,
                %{
                  uid: auth.uid,
                  name: auth.info.name,
                  avatar: nil,
                  nickname: auth.info.nickname,
                  email: auth.info.email
                }}
    end

    test "handle data without name", %{auth: auth} do
      auth = %Auth{
        uid: auth.uid,
        provider: auth.provider,
        info: %Auth.Info{
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

      assert Runa.Auth.find_or_create(auth) ==
               {:ok,
                %{
                  uid: auth.uid,
                  name: "#{auth.info.first_name} #{auth.info.last_name}",
                  avatar: auth.info.urls.avatar_url,
                  nickname: auth.info.nickname,
                  email: auth.info.email
                }}
    end

    test "handle data without name, first name", %{auth: auth} do
      auth = %Auth{
        uid: auth.uid,
        provider: auth.provider,
        info: %Auth.Info{
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

      assert Runa.Auth.find_or_create(auth) ==
               {:ok,
                %{
                  uid: auth.uid,
                  name: auth.info.last_name,
                  avatar: auth.info.urls.avatar_url,
                  nickname: auth.info.nickname,
                  email: auth.info.email
                }}
    end

    test "handle data without name, last name", %{auth: auth} do
      auth = %Auth{
        uid: auth.uid,
        provider: auth.provider,
        info: %Auth.Info{
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

      assert Runa.Auth.find_or_create(auth) ==
               {:ok,
                %{
                  uid: auth.uid,
                  name: auth.info.first_name,
                  avatar: auth.info.urls.avatar_url,
                  nickname: auth.info.nickname,
                  email: auth.info.email
                }}
    end

    test "handle data without name, first name, last name", %{auth: auth} do
      auth = %Auth{
        uid: auth.uid,
        provider: auth.provider,
        info: %Auth.Info{
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

      assert Runa.Auth.find_or_create(auth) ==
               {:ok,
                %{
                  uid: auth.uid,
                  name: auth.info.nickname,
                  avatar: auth.info.urls.avatar_url,
                  nickname: auth.info.nickname,
                  email: auth.info.email
                }}
    end

    test "handle data without name, first name, last name, nickname", %{auth: auth} do
      auth = %Auth{
        uid: auth.uid,
        provider: auth.provider,
        info: %Auth.Info{
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

      assert Runa.Auth.find_or_create(auth) ==
               {:ok,
                %{
                  uid: auth.uid,
                  name: auth.info.email,
                  avatar: auth.info.urls.avatar_url,
                  nickname: auth.info.nickname,
                  email: auth.info.email
                }}
    end

    test "handle data without nickname", %{auth: auth} do
      auth = %Auth{
        uid: auth.uid,
        provider: auth.provider,
        info: %Auth.Info{
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

      assert Runa.Auth.find_or_create(auth) ==
               {:ok,
                %{
                  uid: auth.uid,
                  name: auth.info.name,
                  avatar: auth.info.urls.avatar_url,
                  nickname: nil,
                  email: auth.info.email
                }}
    end

    test "handle data without email", %{auth: auth} do
      auth = %Auth{
        uid: auth.uid,
        provider: auth.provider,
        info: %Auth.Info{
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

      assert Runa.Auth.find_or_create(auth) ==
               {:error, "Required authentication information is missing."}
    end

    test "handle data without uid", %{auth: auth} do
      auth = %Auth{
        provider: auth.provider,
        info: %Auth.Info{
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

      assert Runa.Auth.find_or_create(auth) ==
               {:error, "Required authentication information is missing."}
    end

    test "handle data with incorrect changeset", %{auth: auth} do
      auth = %Auth{
        uid: 1,
        provider: auth.provider,
        info: %Auth.Info{
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

      assert {:error, "Failed to create user"} == Runa.Auth.find_or_create(auth)
    end
  end

  describe "authorization module for auth0 provider affects db" do
    setup [:create_aux_success_auth]

    test "create user", %{auth: auth} do
      assert [] == Accounts.list_users()

      assert {:ok, user} = Runa.Auth.find_or_create(auth)

      assert [new] = Accounts.list_users()

      assert user == Map.take(new, [:uid, :name, :avatar, :nickname, :email])
    end

    test "return existing user", %{auth: auth} do
      assert [] == Accounts.list_users()

      assert {:ok, user} = Runa.Auth.find_or_create(auth)

      assert {:ok, ^user} = Runa.Auth.find_or_create(auth)
    end
  end
end
