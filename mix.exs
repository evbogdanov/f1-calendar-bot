defmodule F1CalendarBot.Mixfile do
  use Mix.Project

  @version "0.1.0"

  def project do
    [app: :f1_calendar_bot,
     version: @version,
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     source_url: "https://github.com/evbogdanov/f1_calendar_bot",
     homepage_url: "https://telegram.me/F1CalendarBot",
     description: "@F1CalendarBot for Telegram"]
  end

  def application do
    [extra_applications: [:logger],
     mod: {F1CalendarBot, []}]
  end

  defp deps do
    [{:poison, "~> 3.0"},
     {:hackney, "~> 1.6"}]
  end
end
