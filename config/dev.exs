import Config

config :do_it, DoIt.Commfig,
  dirname: System.tmp_dir(),
  filename: "solr_cli.json"
