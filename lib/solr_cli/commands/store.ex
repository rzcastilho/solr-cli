defmodule SolrCli.Commands.Store do
  use DoIt.Command,
    description: "Solr CLI Key Store"

  subcommand(SolrCli.Commands.Store.Url)
  subcommand(SolrCli.Commands.Store.Template)

end
