# F1CalendarBot

@F1CalendarBot for Telegram

![](priv/botpic.png)

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

## Commands

- `/next` - When is the next Grand Prix
- `/prev` - When was the previous Grand Prix

## Testing

```
$ mix test
```
