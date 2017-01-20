defmodule F1CalendarBot.Cal do

  def parse_date(string) do
    [year, month, day] = string |> String.split("-")
                                |> Enum.map(&String.to_integer/1)
    {:ok, date} = Date.new(year, month, day)
    date
  end

  def days_between(date1, date2) do
    days1 = Date.to_erl(date1) |> :calendar.date_to_gregorian_days()
    days2 = Date.to_erl(date2) |> :calendar.date_to_gregorian_days()
    abs(days1 - days2)
  end

end
