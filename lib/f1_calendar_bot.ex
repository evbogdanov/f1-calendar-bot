defmodule F1CalendarBot do
  use Application

  def start(_type, _args) do
    F1CalendarBot.Supervisor.start_link
  end
end
