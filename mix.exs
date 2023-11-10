defmodule SolrCli.MixProject do
  use Mix.Project

  def project do
    [
      app: :solr_cli,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: [main_module: SolrCli]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:do_it, "~> 0.6"},
      {:tesla, "~> 1.7"},
      {:plug, "~> 1.14"},
      {:geo, "~> 3.5"}
    ]
  end
end
