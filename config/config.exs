use Mix.Config

# Timeout in seconds for Telegram long polling.
config :f1_calendar_bot, long_polling_timeout: 50

import_config "token.exs"
