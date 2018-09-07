
defmodule PongWeb.LobbyChannel do
  use PongWeb, :chanel

  alias Pong.Application
  alias Pong.Lobby
  
  def join("lobby:find_lobby", _params, socket) do
    send(self(), :after_join)
  end

  def handle_info(:after_join, socket) do
    case lobbies = Lobby.get_lobby() do
      "lobby:" <> lobby_id ->
        {:ok, lobby_id}
      :nil ->
        lobby_id = random_string(6)
        Supervisor.start_child(Pong.Supervisor, {
          PongWeb.Lobby, lobby_id: lobby_id
        })
        {:ok, lobby_id}
  end

  defp random_string(str_len) do
    :crypto.strong_rand_bytes(str_len)
    |> Base.url_encode64 
    |> binary_part(0, str_len)
  end

end
