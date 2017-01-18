# F1CalendarBot

@F1CalendarBot for Telegram

## Installation

To access the Telegram API, get token from BotFather and put it in `config/token.exs`
```
use Mix.Config

config :f1_calendar_bot, token: "Here goes my token"
```

Then, get dependencies and compile everything:
```
$ mix deps.get
$ mix compile
```

## Testing

```
$ mix test
```
