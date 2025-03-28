defmodule FlashSyncE.MixProject do
  use Mix.Project

  def project do
    [
      app: :flash_sync_e,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {FlashSyncE.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cowboy, "~> 2.13"},
      {:plug_cowboy, "~> 2.7.3"},
      {:jason, "~> 1.4.4"},
      {:postgrex, "~> 0.20"},
      {:ecto_sql, "~> 3.12.1"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
