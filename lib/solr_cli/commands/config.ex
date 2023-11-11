defmodule SolrCli.Commands.Config do
  use DoIt.Command,
    description: "Solr CLI Configuration"

  subcommand(SolrCli.Commands.Config.Url)
  subcommand(SolrCli.Commands.Config.Template)

end
