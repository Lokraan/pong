defmodule Ping.Lobby do

  use GenServer

  alias __MODULE__
  defstruct(
    id: :string,
    players: %{},
    max_players: 6
  )

  def start_link(opts) do
    lobby_id = Keyword.fetch!(opts, :lobby_id)
    
    IO.inspect GenServer.start_link(__MODULE__, [lobby_id], 
      name: {:via, Registry, {Ping.LobbyRegistry, lobby_id}}
    )

    #IO.inspect pid

    #Process.monitor(pid)
    
    #IO.inspect pid, label: "pid"
    #{:ok, pid}
  end

  def init([lobby_id]) do
    IO.inspect lobby_id, label: :init
    state = %Lobby{id: lobby_id}

    {:ok, state, state}
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
    IO.inspect find_lobby!(lobby_id)

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
    players = length(Map.keys(state.players))
    if players < state.max_players do

      new_players = Map.put(state.players, player.user_id, player)

      response = ((players + 1) == state.max_players) && :now_full || :ok
      {:reply, response, %{state | players: new_players}}
    else
      {:reply, :lobby_already_full, state}
    end
  end

  def handle_call({:player_leave, player_id}, _from, state) do
    new_players = Map.delete(state.players, player_id)
    {:reply, :ok, %{state | players: new_players}}
  end 
end
