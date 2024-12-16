defmodule Runa.MixProject do
  use Mix.Project

  def project do
    [
      app: :runa,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      preferred_cli_env: [
        "test.watch": :test
      ],
      elixirc_options: [
        debug_info: true,
        verbose: true,
        all_warnings: true
      ],
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.lcov": :test,
        "coveralls.html": :test,
        "coveralls.cobertura": :test
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Runa.Application, []},
      extra_applications: [
        :ueberauth,
        :ueberauth_auth0,
        :ueberauth_google,
        :logger,
        :runtime_tools
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(:dev), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:poison, "~> 5.0"},
      {:ueberauth_auth0, "~> 2.0"},
      {:ueberauth_google, "~> 0.12"},
      {:ueberauth, "~> 0.10"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.18", only: :test},
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false},
      {:phoenix, "~> 1.7.11"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 4.0"},
      {:phoenix_live_reload, "~> 1.5", only: :dev},
      {:phoenix_live_view, "~> 1.0.0"},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.1.1"},
      {:plug_cowboy, "~> 2.7"},
      {:floki, "~> 0.36.0", only: :test},
      {:pathex, "~> 2.0"},
      {:tailwind, "~> 0.2.2"},
      {:csv, "~> 3.2"},
      {:mock, "~> 0.3.0", only: :test},
      {:repatch, "~> 1.0", only: :test},
      {:jsonapi, "~> 1.7.1"},
      {:ex_machina, "~> 2.7.0", only: [:dev, :test]},
      {:recode, "~> 0.7", only: [:dev, :test]},
      {:open_api_spex, "~> 3.21.1"},
      {:flop, "~> 0.25.0"},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:file_system, "~> 1.0", only: [:dev, :test]},
      {:typed_ecto_schema, "~> 0.4.1", runtime: false},
      {:dotenvy, "~> 0.8.0", only: [:dev, :test]},
      {:faker, "~> 0.18", only: [:dev, :test]},
      {:pbkdf2_elixir, "~> 2.0"},
      {:tails, "~> 0.1.11"},
      {:live_isolated_component, "~> 0.9.0", only: [:dev, :test]}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      start: ["deps", "phx.server"],
      deps: ["deps.get", "deps.compile"],
      setup: [
        "deps.get",
        "ecto.setup",
        "assets.setup",
        "assets.build"
      ],
      "ecto.seed": [
        "seed.languages",
        "seed.data"
      ],
      "ecto.setup": [
        "ecto.create",
        "ecto.migrate"
      ],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: [
        "ecto.create --quiet",
        "ecto.migrate --quiet",
        "test"
      ],
      "test.watch.only": ["test.watch --only only"],
      "test.format": ["credo", "format --check-formatted"],
      "assets.setup": ["esbuild.install --if-missing"],
      "assets.build": ["esbuild runa"],
      "assets.deploy": [
        "tailwind default --minify",
        "esbuild runa --minify",
        "phx.digest"
      ],
      deploy: [
        "deps.get --only prod",
        "cmd MIX_ENV=prod mix compile",
        "cmd MIX_ENV=prod mix assets.deploy",
        "phx.gen.release --docker",
        "cmd MIX_ENV=prod mix release --overwrite"
      ]
    ]
  end
end
