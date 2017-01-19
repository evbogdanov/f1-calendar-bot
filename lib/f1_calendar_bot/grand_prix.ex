defmodule F1CalendarBot.GrandPrix do
  @derive [Poison.Encoder]
  defstruct [:name, :date]

  alias F1CalendarBot.GrandPrix
  alias F1CalendarBot.Cal

  ## API
  ## -----------------------------------------------------------------------------

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

  def sort(grands_prix) do
    Enum.sort(grands_prix, fn(gp1, gp2) ->
      cmp = Date.compare(gp1.date, gp2.date)
      cmp == :eq or cmp == :lt
    end)
  end

  def next(grands_prix, today \\ Date.utc_today()) do
    grands_prix
    |> sort()
    |> find_next(today)
  end

  def prev(grands_prix, today \\ Date.utc_today()) do
    grands_prix
    |> sort()
    |> Enum.reverse()
    |> find_prev(today)
  end

  ## INTERNAL FUNCTIONS   
  ## -----------------------------------------------------------------------------

  defp find_next([], _today), do: nil

  defp find_next([%GrandPrix{date: date} = gp | gps], today) do
    case Date.compare(today, date) do
      :lt -> gp
      :eq -> gp
      :gt -> find_next(gps, today)
    end
  end

  defp find_prev([], _today), do: nil
  
  defp find_prev([%GrandPrix{date: date} = gp | gps], today) do
    case Date.compare(today, date) do
      :gt -> gp
      _le -> find_prev(gps, today)
    end
  end

end
