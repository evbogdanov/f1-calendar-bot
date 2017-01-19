defmodule F1CalendarBot.Telegram do

  @token Application.get_env(:f1_calendar_bot, :token)
  @url "https://api.telegram.org/bot#{@token}/"
  @timeout Application.get_env(:f1_calendar_bot, :long_polling_timeout)

  ## API
  ## -----------------------------------------------------------------------------

  def get_me, do: call_method("getMe")

  def get_updates do
    # Get updates without long polling
    call_method("getUpdates")
  end

  def get_updates_async(offset) do
    # Get updates asynchronously with long polling
    call_method(
      "getUpdates",
      %{"offset" => offset, "timeout" => @timeout},
      [:async, {:recv_timeout, (@timeout + 5) * 1000}]
    )
  end

  def send_message(chat_id, text) do
    call_method("sendMessage", %{"chat_id" => chat_id, "text" => text})
  end

  def updates_offset(updates, default_offset \\ 0) do
    case (updates |> Enum.map(fn(%{"update_id" => id}) -> id end)) do
      []  -> default_offset
      ids -> Enum.max(ids) + 1
    end
  end

  ## INTERNAL FUNCTIONS
  ## -----------------------------------------------------------------------------

  defp call_method(method_name), do: call_method(method_name, %{})

  defp call_method(method_name, params, opts \\ []) do
    url = "#{@url}#{method_name}"
    headers = [{"Content-Type", "application/json; charset=utf-8"},
               {"Accept", "application/json"}]
    json = Poison.encode!(params)
    case :hackney.request("POST", url, headers, json, opts) do
      {:ok, 200, _, body_ref} ->
        {:ok, body} = :hackney.body(body_ref)
        case Poison.decode(body) do
          {:ok, %{"ok" => true, "result" => result}} ->
            {:ok, result}
          _not_ok ->
            {:error, "Unexpected result"}
        end
      {:ok, status, _headers, _body_ref} ->
        {:error, "Status: #{status}"}
      {:ok, client_ref} ->
        # Response will be fetched asynchronously
        {:ok, client_ref}
      {:error, reason} ->
        {:error, reason}
    end
  end

end
