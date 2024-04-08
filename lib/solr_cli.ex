defmodule SolrCli do
  use DoIt.MainCommand,
    description: "Solr CLI Collections Utility"

  command(SolrCli.Commands.Store)
  command(SolrCli.Commands.Maintain)
  command(SolrCli.Commands.Copy)
  command(SolrCli.Commands.Config)
end
