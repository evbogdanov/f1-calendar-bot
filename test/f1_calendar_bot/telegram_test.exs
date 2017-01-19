defmodule F1CalendarBot.TelegramTest do
  use ExUnit.Case

  alias F1CalendarBot.Telegram

  test "auth token" do
    assert {:ok, %{"id" => 306224622, "username" => "F1CalendarBot"}}
    = Telegram.get_me()
  end

  test "getting updates" do
    assert {:ok, updates} = Telegram.get_updates()
    assert is_list(updates)
    if length(updates) > 0 do
      assert %{"message" => _, "update_id" => _} = hd(updates)
    end
  end

  test "sending text messages" do
    assert {:ok, %{"chat" => %{"id" => 295371074},
                   "from" => %{"id" => 306224622, "username" => "F1CalendarBot"},
                   "text" => "hello, ev"}}
    = Telegram.send_message(295371074, "hello, ev")
  end

  test "offset = update_id of last processed update + 1" do
    assert 0  == Telegram.updates_offset([])
    assert 13 == Telegram.updates_offset([], 13)
    
    updates = [%{"message" => %{},
                 "update_id" => 1},
               %{"message" => %{},
                 "update_id" => 2},
               %{"message" => %{},
                 "update_id" => 3}]
    assert 4 == Telegram.updates_offset(updates)
    assert 4 == Telegram.updates_offset(updates, 13)
  end

end
