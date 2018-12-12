defmodule Ping.Lobby do

  use GenServer

  alias __MODULE__
  defstruct(
    id: :wow,
    players: %{},
    max_players: 6
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
      max_players: Application.get_env(:ping, Ping, [])[:max_players] || 6
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

  def topic(lobby_id), do: "lobby:#{lobby_id}"

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

  def handle_call(:get_players, _from, state), do: {:reply, state.players, state}

  def handle_call(:get_id, _from, state), do: {:reply, state.id, state}

  def handle_call({:update_id, new_id}, _from, state) do
    new_state = %{state | id: new_id}
    {:reply, :ok, new_state}
  end

  def handle_call({:player_join, player}, _from, state) do
    IO.inspect state.players, label: :players
    IO.inspect player, label: :player
    players = length(Map.keys(state.players))
    if not Map.has_key?(state.players, player.user_id) do
      if players < state.max_players do

        new_players = Map.put(state.players, player.user_id, player)

        response = ((players + 1) == state.max_players) && :now_full || :ok
        {:reply, response, %{state | players: new_players}}
      else
        {:reply, :full, state}
      end
    else
      {:reply, :already_joined, state}
    end
  end

  def handle_call({:player_leave, player_id}, _from, state) do
    new_players = Map.delete(state.players, player_id)
    {:reply, :ok, %{state | players: new_players}}
  end

  @spec config(atom()) :: term
  defp config(key) do
    Application.get_env(:ping, Ping, [])[key]
  end
end
