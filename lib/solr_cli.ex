defmodule SolrCli do
  use DoIt.MainCommand,
    description: "Solr CLI Utils"

  command(SolrCli.Commands.Config)
  command(SolrCli.Commands.Copy)
end
