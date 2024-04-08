defmodule SolrCli.Commands.Maintain do
  use DoIt.Command,
    description: "Solr maintenance commands"

  subcommand(SolrCli.Commands.Maintain.Backup)
  subcommand(SolrCli.Commands.Maintain.Restore)
  subcommand(SolrCli.Commands.Maintain.Status)

end
