defmodule F1CalendarBot.CalTest do
  use ExUnit.Case

  alias F1CalendarBot.Cal

  test "date from string" do
    assert ~D[2017-03-26] = Cal.parse_date("2017-03-26")
  end

end
