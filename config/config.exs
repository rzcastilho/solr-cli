import Config

config :elixir, :ansi_enabled, true

import_config "#{config_env()}.exs"
