defmodule F1CalendarBot.GrandPrix do
  @derive [Poison.Encoder]
  defstruct [:name, :date]

  alias F1CalendarBot.GrandPrix
  alias F1CalendarBot.Cal

  def from_file_in_priv_dir(file_name) do
    priv_dir = Application.app_dir(:f1_calendar_bot, "priv")
    path     = Path.join(priv_dir, file_name)
    
    {:ok, json} = File.read(path)
    decoded     = Poison.decode!(json, as: %{"grands_prix" => [%GrandPrix{}]})

    Enum.map(decoded["grands_prix"], fn(gp) ->
      date = Cal.parse_date(gp.date)
      %{gp | date: date}
    end)
  end

end
