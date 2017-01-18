defmodule F1CalendarBot.Cal do

  def parse_date(string) do
    [year, month, day] = string |> String.split("-")
                                |> Enum.map(&String.to_integer/1)
    {:ok, date} = Date.new(year, month, day)
    date
  end

end
