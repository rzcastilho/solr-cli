import Config

config :do_it, DoIt.Commfig,
  dirname: System.user_home(),
  filename: "solr_cli.json"
