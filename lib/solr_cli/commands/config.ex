defmodule SolrCli.Commands.Config do
  use DoIt.Command,
    description: "Solr Collections Configuration"

  subcommand(SolrCli.Commands.Config.Create)
  subcommand(SolrCli.Commands.Config.Delete)
end
