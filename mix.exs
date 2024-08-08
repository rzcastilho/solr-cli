defmodule SolrCli.MixProject do
  use Mix.Project

  def project do
    [
      app: :solr_cli,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: releases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :do_it],
      mod: {SolrCli, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:do_it, "~> 0.6.1"},
      {:tesla, "~> 1.7"},
      {:plug, "~> 1.14"},
      {:geo, "~> 3.5"},
      {:burrito, "~> 1.1.0"},
      {:table_rex, "~> 4.0"}
    ]
  end

  def releases do
    [
      solr_cli: [
        steps: [:assemble, &Burrito.wrap/1],
        burrito: [
          targets: [
            linux: [os: :linux, cpu: :x86_64],
            macos: [os: :darwin, cpu: :x86_64],
            windows: [os: :windows, cpu: :x86_64]
          ]
        ]
      ]
    ]
  end
end
