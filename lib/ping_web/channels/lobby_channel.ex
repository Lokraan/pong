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
  def join("lobby:find", _params, socket) do
    lobbies = DynamicSupervisor.which_children(LobbySupervisor)
    case lobbies do
      [] ->
        # generate a new lobby
        lobby_id = gen_id()

        {:ok, pid} = DynamicSupervisor.start_child(LobbySupervisor,
          {Lobby, lobby_id: lobby_id})

        lobby_id = Lobby.get_id(pid)

        {:ok, topic(lobby_id), socket}

      # lobbies do exist
      [{:undefined, pid, _, _} | _] ->
        lobby_id = Lobby.get_id(pid)

        {:ok, topic(lobby_id), socket}
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
    player = %{
      user_id: socket.assigns.user_id,
      username: socket.assigns.username
    }

    case Lobby.player_join(lobby_id, player) do
      :ok ->
        socket = assign(socket, :lobby_id, lobby_id)

        resp =
          lobby_id
          |> Lobby.get_state()
          |> get_lobby_resp()

        {:ok, resp, socket}

      {:now_full, players} ->
        socket = assign(socket, :lobby_id, lobby_id)

        start_game(lobby_id, players, socket)

      :already_joined ->
        socket = assign(socket, :lobby_id, lobby_id)

        resp =
          lobby_id
          |> Lobby.get_state()
          |> get_lobby_resp()

        {:ok, resp, socket}

      :full ->
        {:error, :full}
    end
  end

  def start_game(lobby_id, players, socket) do
    game_id = gen_id()
    {:ok, _pid} = DynamicSupervisor.start_child(Ping.GameSupervisor, {
      Ping.Game, game_id: game_id, players: players
    })

    PingWeb.Endpoint.broadcast!(topic(lobby_id), "game:start",
      %{game_id: game_id})

    {:ok, %{game_id: game_id}, socket}
  end

  def broadcast_update(lobby_id, data) do
    lobby_id
    |> topic()
    |> PingWeb.Endpoint.broadcast!("lobby:update", get_lobby_resp(data))
  end

  @doc """
  Handles a player's leave.
  """
  def handle_in("lobby:leave", _, socket) do
    IO.inspect "handling leave"
    lobby_id = socket.assigns.lobby_id
    user_id = socket.assigns.user_id

    Lobby.player_leave(lobby_id, user_id)

    {:reply, {:ok, %{}}, socket}
  end

  def handle_in("force_start:upvote", _, socket) do
    lobby_id = socket.assigns.lobby_id
    user_id = socket.assigns.user_id

    case Lobby.force_start_vote(lobby_id, user_id) do
      {:force_start, players} ->
        start_game(lobby_id, players, socket)

      _ ->
        {:reply, :ok, socket}
    end
  end

  defp get_lobby_resp(%Lobby{} = lobby_state) do
    votes = MapSet.size(lobby_state.force_start_votes)
    p_count = map_size(lobby_state.players)

    %{
      lobby_id: topic(lobby_state.id),
      players: lobby_state.players,
      force_start_status: "#{votes}/#{p_count}"
    }
  end

  defp gen_id() do
    :crypto.strong_rand_bytes(8)
    |> Base.url_encode64()
    |> binary_part(0, 8)
  end

  def topic(lobby_id) do
    "lobby:#{lobby_id}"
  end
end
