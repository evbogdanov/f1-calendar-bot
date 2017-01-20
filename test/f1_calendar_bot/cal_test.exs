defmodule F1CalendarBot.CalTest do
  use ExUnit.Case

  alias F1CalendarBot.Cal

  test "date from string" do
    assert ~D[2017-03-26] == Cal.parse_date("2017-03-26")
  end

  test "days between two dates" do
    assert 0 == Cal.days_between(~D[2017-01-01], ~D[2017-01-01])
    assert 1 == Cal.days_between(~D[2017-01-02], ~D[2017-01-01])
    assert 1 == Cal.days_between(~D[2017-01-01], ~D[2017-01-02])
    assert 365 == Cal.days_between(~D[2017-01-01], ~D[2018-01-01])
  end

end
