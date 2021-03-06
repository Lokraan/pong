
defmodule PongWeb.LobbyChannel do
  @moduledoc """
    Controls finding and populating lobbies for games.
  """

  use PongWeb, :channel

  alias Pong.Application
  alias Pong.Lobby
  alias Pong.Player
  
  @doc """
    All users are ported to the default `find_lobby` lobby.
  At this point all existing lobby processes are retrieved
  from the LobbySupervisord. If none exist, then a new lobby
  is generated and the player is assigned to it. If lobbies do
  exist then the player is assigned to one at random.
  """
  def join("lobby:find_lobby", _params, socket) do
    lobbies = DynamicSupervisor.which_children(Pong.LobbySupervisor)
    case lobbies do
      # no lobbies exist
      [] -> 
        # generate a new lobby
        lobby_id = gen_id()
        DynamicSupervisor.start_child(Pong.LobbySupervisor, {
          Lobby, lobby_id: lobby_id})
        
        {:ok, lobby_id}

      # lobbies do exist
      _ ->
        {:undefined, pid, _, _} = Enum.random(lobbies)
        lobby_id = Lobby.get_id(pid)

        {:ok, lobby_id}
    end
  end

  @doc """
    Handles players joining the lobby by calling `Lobby.player_join`
  and handling the responses from the function.
    On `:ok` the player succesfully joined the lobby and the lobby_id
  is assigned to the socket. After this `{:ok, "Joined"}` is
  returned.
    On `:full` the player that just joined was the last player to be
  able to join and the game is now being created. After the game is 
  created, the game_id is broadcasted to all players in the lobby.
    On `:lobby_already_full` the lobby has already been filled up,
  returns `{:error, "Lobby already full."}
  """
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

  @doc """
    Handles player leaving by calling `Lobby.player_leave`
  """
  def handle_in(:player_leave, socket) do
    lobby_id = socket.assigns.lobby_id
    user_id = socket.assigns.user_id
    Lobby.player_leave(lobby_id, user_id)
  end

  @doc """
    Generates a random for the lobby out of 8 bytes.
  (2^64 possibilities)
  """
  defp gen_id() do
    :crypto.strong_rand_bytes(8)
    |> Base.url_encode64()
    |> binary_part(0, 8)
  end

end
