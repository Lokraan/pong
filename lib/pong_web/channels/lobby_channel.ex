
defmodule PongWeb.LobbyChannel do
  use PongWeb, :channel

  alias Pong.Application
  alias Pong.Lobby
  alias Pong.Player
  
  def join("lobby:find_lobby", _params, socket) do
    lobbies = DynamicSupervisor.which_children(Pong.LobbySupervisor)
    case lobbies do
      [] -> 
        lobby_id = gen_id()
        DynamicSupervisor.start_child(Pong.LobbySupervisor, {
          Lobby, lobby_id: lobby_id})
        
        assign(socket, :lobby_id, lobby_id)

        {:ok, lobby_id}
      _ ->
        {:undefined, pid, _, _} = Enum.random(lobbies)
        lobby_id = Lobby.get_id(pid)
        
        assign(socket, :lobby_id, lobby_id)

        {:ok, lobby_id}
    end
  end

  def join("lobby:" <> lobby_id, _params, socket) do
    player = %Player{
      id: socket.assigns.user_id,
      name: socket.assigns.username
    }

    case Lobby.player_join(lobby_id, player) do
      :ok, ->
        assign(socket, :lobby_id, lobby_id)

        {:ok, "Joined"}

      :full ->
        assign(socket, :lobby_id, lobby_id)

        game_id = get_id()
        players = Lobby.get_players()
        DynamicSupervisor.start_child(Pong.GameSupervisor, {
          Pong.Game, game_id: game_id, players: players
        })

        Pong.Endpoint.broadcast!(lobby_id, "game_start", game_id)

        {:ok, "Last player joined."}

      :lobby_already_full ->
        {:error, "Lobby is full"} # search for a new lobby
    end
  end

  def handle_in(:player_leave, socket) do
    lobby_id = socket.assigns.lobby_id
    user_id = socket.assigns.user_id
    Lobby.player_leave(lobby_id, user_id)
  end

  defp gen_id() do
    :crypto.strong_rand_bytes(8)
    |> Base.url_encode64()
    |> binary_part(0, 8)
  end

end
