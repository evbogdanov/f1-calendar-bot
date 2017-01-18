defmodule F1CalendarBot.GrandPrixTest do
  use ExUnit.Case

  alias F1CalendarBot.GrandPrix

  test "grands prix in season 2017" do
    grands_prix = GrandPrix.from_file_in_priv_dir("2017.json")
    assert length(grands_prix) == 20
    
    %GrandPrix{date: date, name: name} = hd(grands_prix)
    assert date == ~D[2017-03-26]
    assert name == "Australian Grand Prix"
  end

end
