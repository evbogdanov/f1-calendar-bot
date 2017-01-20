defmodule F1CalendarBot.Telegram.Server do
  use GenServer

  alias F1CalendarBot.Telegram
  alias F1CalendarBot.GrandPrix

  ## API
  ## -----------------------------------------------------------------------------

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  ## SERVER CALLBACKS
  ## -----------------------------------------------------------------------------

  def init(:ok) do
    # Initial state
    offset = 0
    body   = ""

    # Fetch grands prix for 2017 season
    gps     = GrandPrix.from_file_in_priv_dir("2017.json")
    gp_next = GrandPrix.next(gps)
    gp_prev = GrandPrix.prev(gps)
    # TODO: `send_after` to recalculate gp_next and gp_prev

    # Start long polling.
    # Return client_ref to fetch updates later in `handle_info`.
    {:ok, ref} = Telegram.get_updates_async(offset)

    state = %{offset:     offset,
              client_ref: ref,
              body:       body,
              gps:        gps,
              gp_next:    gp_next,
              gp_prev:    gp_prev}
    {:ok, state}
  end

  def handle_info({:hackney_response, ref, res}, %{client_ref: ref} = state) do
    case res do
      {:status, status_int, status_str} ->
        IO.puts("Got status: #{status_int} -- #{status_str}")
        {:noreply, state}
      {:headers, _headers} ->
        IO.puts("Got headers")
        {:noreply, state}
      :done ->
        updates = case Poison.decode(state.body) do
                    {:ok, %{"ok" => true, "result" => result}} ->
                      result
                    tg_res ->
                      :error_logger.warning_msg('Unexpected TG response: ~p~n',
                                                [tg_res])
                      []
                  end
        offset2 = Telegram.updates_offset(updates, state.offset)

        # Send messages to users
        Enum.each(updates, fn(upd) -> handle_update(upd, state) end)

        # Continue the polling
        {:ok, ref2} = Telegram.get_updates_async(offset2)
        state2 = %{state | :offset     => offset2,
                           :client_ref => ref2,
                           :body       => ""}
        
        {:noreply, state2}
      body ->
        IO.puts("Got body")
        state2 = %{state | :body => body}
        {:noreply, state2}
    end
  end

  def handle_info({:hackney_response, ref, _res}, state) do
    :error_logger.warning_msg('Unexpected hackney ref: ~p~n', [ref])
    {:noreply, state}
  end

  def handle_info(_info, state) do
    {:noreply, state}
  end

  ## INTERNAL FUNCTIONS
  ## -----------------------------------------------------------------------------

  defp handle_update(
    %{"message" => %{"from" => %{"id" => id}, "text" => text}},
    state
  ) do
    msg = case text do
            "/next" ->
              GrandPrix.when_next(state.gp_next)
            "/prev" ->
              GrandPrix.when_prev(state.gp_prev)
            _unknown ->
              "What'd you like to know?\n\n" <>
              "/next - When is the next Grand Prix\n" <>
              "/prev - When was the previous Grand Prix"
          end
    Telegram.send_message(id, msg)
  end

  defp handle_update(upd, _state) do
    :error_logger.warning_msg('Unexpected update: ~p~n', [upd])
  end

end
