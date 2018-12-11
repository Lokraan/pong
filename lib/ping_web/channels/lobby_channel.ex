defmodule PingWeb.LobbyChannel do
  @moduledoc """
    Controls finding and populating lobbies for games.
  """

  use PingWeb, :channel

  alias Ping.{Lobby, LobbySupervisor}

  @doc """
  All users are ported to the default `find_lobby` lobby.
  At this point all existing lobby processes are retrieved
  from the LobbySupervisord. If none exist, then a new lobby
  is generated and the player is assigned to it. If lobbies do
  exist then the player is assigned to one at random.
  """
  def join("lobby:find", _params, _socket) do
    lobbies = DynamicSupervisor.which_children(LobbySupervisor)
    IO.puts "this guy wants to join"
    case lobbies do
      # no lobbies exist
      [] -> 
        # generate a new lobby
        lobby_id = gen_id()

        {:ok, pid} = DynamicSupervisor.start_child(LobbySupervisor, 
          {Lobby, lobby_id: lobby_id}) 
        lobby_id = Lobby.get_id(pid)

        {:ok, lobby_id}

      # lobbies do exist
      [h | _] ->
        {:undefined, pid, _, _} = h
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
    IO.puts "this guy wants to join2"
    player = %{
      user_id: socket.assigns.user_id,
      username: socket.assigns.username
    }

    case Lobby.player_join(lobby_id, player) do
      :ok ->
        assign(socket, :lobby_id, lobby_id)

        {:ok, :joined}

      :now_full ->
        assign(socket, :lobby_id, lobby_id)

        game_id = gen_id()
        players = Lobby.get_players(lobby_id)
        DynamicSupervisor.start_child(Ping.GameSupervisor, {
          Ping.Game, game_id: game_id, players: players
        })

        PingWeb.Endpoint.broadcast!(Lobby.topic(lobby_id), "game:start",
          %{game_id: game_id})

        {:ok, :joined}

      :lobby_already_full ->
        {:error, :full} # search for a new lobby
    end
  end

  @doc """
  Handles player leaving by calling `Lobby.player_leave`
  """
  def handle_in(:player_leave, _, socket) do
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
