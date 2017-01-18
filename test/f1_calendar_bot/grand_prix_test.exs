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

  test "sorting" do
    grands_prix = [%GrandPrix{name: "3", date: ~D[2017-03-03]},
                   %GrandPrix{name: "1", date: ~D[2017-01-01]},
                   %GrandPrix{name: "2", date: ~D[2017-02-02]}]
    assert GrandPrix.sort(grands_prix) == [%GrandPrix{name: "1", date: ~D[2017-01-01]},
                                           %GrandPrix{name: "2", date: ~D[2017-02-02]},
                                           %GrandPrix{name: "3", date: ~D[2017-03-03]}]
  end

  test "next grand prix not found" do
    assert GrandPrix.next([]) == nil

    grands_prix = [%GrandPrix{name: "1", date: ~D[2017-01-01]},
                   %GrandPrix{name: "2", date: ~D[2017-02-02]}]

    assert GrandPrix.next(grands_prix, ~D[2017-02-03]) == nil
    assert GrandPrix.next(grands_prix, ~D[2017-03-03]) == nil
  end

  test "next grand prix found" do
    grands_prix = [%GrandPrix{name: "1", date: ~D[2017-01-01]},
                   %GrandPrix{name: "2", date: ~D[2017-02-02]}]

    assert GrandPrix.next(grands_prix, ~D[2016-12-12])
    == %GrandPrix{name: "1", date: ~D[2017-01-01]}

    assert GrandPrix.next(grands_prix, ~D[2017-01-01])
    == %GrandPrix{name: "1", date: ~D[2017-01-01]}

    assert GrandPrix.next(grands_prix, ~D[2017-01-02])
    == %GrandPrix{name: "2", date: ~D[2017-02-02]}

    assert GrandPrix.next(grands_prix, ~D[2017-02-02])
    == %GrandPrix{name: "2", date: ~D[2017-02-02]}
  end

  test "previous grand prix not found" do
    assert GrandPrix.prev([]) == nil

    grands_prix = [%GrandPrix{name: "1", date: ~D[2017-01-01]},
                   %GrandPrix{name: "2", date: ~D[2017-02-02]}]

    assert GrandPrix.prev(grands_prix, ~D[2016-12-12]) == nil
    assert GrandPrix.prev(grands_prix, ~D[2017-01-01]) == nil
  end

  test "previous grand prix found" do
    grands_prix = [%GrandPrix{name: "1", date: ~D[2017-01-01]},
                   %GrandPrix{name: "2", date: ~D[2017-02-02]}]

    assert GrandPrix.prev(grands_prix, ~D[2017-03-03])
    == %GrandPrix{name: "2", date: ~D[2017-02-02]}

    assert GrandPrix.prev(grands_prix, ~D[2017-02-02])
    == %GrandPrix{name: "1", date: ~D[2017-01-01]}
  end

end
