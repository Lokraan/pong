defmodule Ping.Lobby do
  use GenServer

  alias __MODULE__
  alias PingWeb.LobbyChannel

  defstruct(
    id: :wow,
    players: %{},
    max_players: 6,
    force_start_votes: MapSet.new()
  )

  def start_link(opts) do
    lobby_id = Keyword.fetch!(opts, :lobby_id)

    GenServer.start_link(__MODULE__, [lobby_id],
      name: {:via, Registry, {Ping.LobbyRegistry, lobby_id}}
    )
  end

  def init([lobby_id]) do
    state = %Lobby{
      id: lobby_id,
      max_players: config(:max_players) || 6
    }

    {:ok, state}
  end

  def find_lobby!(lobby_id) do
    case Registry.lookup(Ping.LobbyRegistry, lobby_id) do
      [{pid, _}] ->
        pid
      [] ->
        raise ArgumentError, "Lobby not found for id #{lobby_id}"
    end
  end

  def get_id(pid), do: GenServer.call(pid, :get_id)

  def player_join(lobby_id, player) do
    lobby_id
    |> find_lobby!()
    |> GenServer.call({:player_join, player})
  end

  def player_leave(lobby_id, player_id) do
    lobby_id
    |> find_lobby!()
    |> GenServer.call({:player_leave, player_id})
  end

  def get_players(lobby_id) do
    lobby_id
    |> find_lobby!()
    |> GenServer.call(:get_players)
  end

  def get_state(lobby_id) do
    lobby_id
    |> find_lobby!()
    |> GenServer.call(:get_state)
  end

  def force_start_vote(lobby_id, player_id) do
    lobby_id
    |> find_lobby!()
    |> GenServer.call({:force_start_upvote, player_id})
  end

  def handle_call(:get_players, _from, state), do: {:reply, state.players, state}

  def handle_call(:get_id, _from, state), do: {:reply, state.id, state}

  def handle_call(:get_state, _from, state), do: {:reply, state, state}

  def handle_call({:update_id, new_id}, _from, state) do
    new_state = %{state | id: new_id}
    {:reply, :ok, new_state}
  end

  def handle_call({:player_join, player}, _from, state) do
    players = length(Map.keys(state.players))

    with {:ok, :not_joined} <- player_joined?(player, state.players),
      {:ok, :not_full} <- is_full?(state) do

      new_players = Map.put(state.players, player.user_id, player.username)

      state =
        state
        |> Map.replace!(:players, new_players)

      if ((players + 1) == state.max_players) do
        {:stop, :shutdown, {:now_full, state.players}, state}
      else
        votes = MapSet.size(state.force_start_votes)
        p_count = map_size(state.players)

        data = %{
          force_start_status: "#{votes}/#{p_count}"
        }

        LobbyChannel.broadcast_force_start_update(state.id, data)

        {:reply, :ok, state}
      end
    else
      {:ok, reason} ->
        {:reply, reason, state}
    end
  end

  def handle_call({:player_leave, player_id}, _from, state) do
    new_players = Map.delete(state.players, player_id)

    {:reply, :ok, %{state | players: new_players}}
  end

  def handle_call({:force_start_upvote, player_id}, _from, state) do
    new_state =
      state
      |> Map.replace!(:force_start_votes, MapSet.put(state.force_start_votes, player_id))

    votes = MapSet.size(new_state.force_start_votes)
    p_count = map_size(state.players)

    data = %{
      force_start_status: "#{votes}/#{p_count}"
    }

    LobbyChannel.broadcast_force_start_update(state.id, data)

    if votes > 1 and votes == p_count do
      {:reply, {:force_start, new_state.players}, new_state}
    else
      {:reply, :ok, new_state}
    end
  end

  @spec config(atom()) :: term
  defp config(key) do
    Application.get_env(:ping, Ping, [])[key]
  end

  defp is_full?(state) do
    if length(Map.keys(state.players)) >= state.max_players do
      {:ok, :full}
    else
      {:ok, :not_full}
    end
  end

  defp player_joined?(player, players) do
    if Map.has_key?(players, player.user_id) do
      {:ok, :already_joined}
    else
      {:ok, :not_joined}
    end
  end
end
