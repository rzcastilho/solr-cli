defmodule SolrCli.Commands.Maintain do
  use DoIt.Command,
    description: "Solr Maintenance Commands"

  subcommand(SolrCli.Commands.Maintain.Backup)
  subcommand(SolrCli.Commands.Maintain.Restore)
  subcommand(SolrCli.Commands.Maintain.Status)
end
