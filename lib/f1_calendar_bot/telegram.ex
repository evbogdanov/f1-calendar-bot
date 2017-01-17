defmodule F1CalendarBot.Telegram do

  @token Application.get_env(:f1_calendar_bot, :token)
  @url "https://api.telegram.org/bot#{@token}/"

  ## API
  ## -----------------------------------------------------------------------------

  def get_me, do: call_method("getMe")

  def get_updates, do: call_method("getUpdates")

  def send_message(chat_id, text) do
    call_method("sendMessage", %{"chat_id" => chat_id, "text" => text})
  end

  ## INTERNAL FUNCTIONS
  ## -----------------------------------------------------------------------------

  defp call_method(method_name), do: call_method(method_name, %{})

  defp call_method(method_name, query) do
    url = "#{@url}#{method_name}"
    headers = [{"Content-Type", "application/json; charset=utf-8"},
               {"Accept", "application/json"}]
    json = Poison.encode!(query)
    case :hackney.request("POST", url, headers, json, []) do
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
      {:error, reason} ->
        {:error, reason}
    end
  end

end
