defmodule F1CalendarBot.Telegram.Server do
  use GenServer

  alias F1CalendarBot.Telegram

  ## API
  ## -----------------------------------------------------------------------------

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  ## SERVER CALLBACKS
  ## -----------------------------------------------------------------------------

  def init(:ok) do
    {offset, body} = {0, ""}

    # Start long polling
    {:ok, client_ref} = Telegram.get_updates_async(offset)

    state = %{offset: offset,
              client_ref: client_ref,
              body: body}

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
        Enum.each(updates, &handle_update/1)

        # Continue the polling
        {:ok, ref2} = Telegram.get_updates_async(offset2)
        state2 = %{offset: offset2,
                   client_ref: ref2,
                   body: ""}
        
        {:noreply, state2}
      body ->
        IO.puts("Got body")
        state2 = %{state | :body => body}
        {:noreply, state2}
    end
  end

  def handle_info({:hackney_response, ref, _res}, state) do
    :error_logger.warning_msg('unexpected hackney ref: ~p~n', [ref])
    {:noreply, state}
  end

  def handle_info(_info, state) do
    {:noreply, state}
  end

  ## INTERNAL FUNCTIONS
  ## -----------------------------------------------------------------------------

  def handle_update(%{"message" => %{"from" => %{"id" => id}, "text" => text}}) do
    msg = case text do
            "/next"  -> "Reply to /next"
            "/prev"  -> "Reply to /prev"
            _unknown -> "What'd you like to know?\n\n/next - When is the next Grand Prix\n/prev - When was the previous Grand Prix"
          end
    Telegram.send_message(id, msg)
  end

  def handle_update(upd) do
    :error_logger.warning_msg('Unexpected update: ~p~n', [upd])
  end

end
