defmodule SolrCli.Commands.Collections do
  use DoIt.Command,
    description: "Solr Collections Commands"

  subcommand(SolrCli.Commands.Collections.Status)
  subcommand(SolrCli.Commands.Collections.Copy)
  subcommand(SolrCli.Commands.Collections.Delete)
  subcommand(SolrCli.Commands.Collections.Compare)
end
