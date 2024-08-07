import Config

config :do_it, DoIt.Commfig,
  dirname: Path.join(System.user_home!(), ".solr_cli"),
  filename: "solr_cli.json"
