defmodule Ping.Game do
  @moduledoc """
  This module is the Game module which handles all updates for
  the game it is assigned to.

  Game also has a default struct where the keys `:game_id` and
  `:players` are enforced.
  `defstruct(
    id: :string,
    players: %{},
    balls: %{}
  )`
  """

  use GenServer

  alias Ping.{Player, Ball} 
  alias PingWeb.GameChannel

  @refresh_rate 60 

  @enforce_keys [:game_id, :players]
  
  alias __MODULE__
  defstruct(
    game_id: :string,
    players: %{},
    balls: %{},
    max_players: 6
  )

  @doc """
  The start_link modules, expects `opts` to be passed into
  it and expects opts to contain `:game_id` and `:players`

  TODO
  Set all players x_pos, y_pos, and wall_pos on intialization.

  ## Examples
    
  DynamicSupervisor.start_child(Ping.GameSupervisor, {
    Ping.Game, game_id: "3jda9", players: %{}
  })
  """
  def start_link(opts) do
    game_id = Keyword.fetch!(opts, :game_id)
    player_data = Keyword.fetch!(opts, :players)

    GenServer.start_link(__MODULE__, [game_id, player_data],
      name: {:via, Registry, {Ping.GameRegistry, game_id}}
    )
  end

  @doc """
  Initiator of the genserver, creates the state by setting the
  `:game_id` and `:players` tags.

  ## Examples
  GenServer.start_link(__MODULE__, ["adadsa", %{}],
    name: {:via, Registry, {Ping.GameRegistry, game_id}}
  )
  """
  def init([game_id, players]) do
    new_players = Enum.reduce(players, %{}, fn {id, name}, m ->
      player = %Player{
        username: name
      }
      Map.put(m, id, player)
    end)

    state = %Game{
      game_id: game_id,
      players: new_players,
      max_players: config(:max_players) || 6,
      balls: %{aaa: %Ball{}} 
    }

    schedule_updates()

    {:ok, state}
  end

  def schedule_updates do
    Process.send_after(self(), :update, update_rate())
  end

  @doc """
  Finds the game's PID based on it's id by searching in the
  `Ping.GameRegistry`.
  """
  def find_game!(game_id) do
    case Registry.lookup(Ping.GameRegistry, game_id) do
      [{pid, _}] ->
        pid
      [] ->
        raise ArgumentError, "Game not found for id #{game_id}"
    end
  end

  def find_game(game_id) do
    case Registry.lookup(Ping.GameRegistry, game_id) do
      [{pid, _}] ->
        {:ok, pid}
      [] ->
        {:error, nil}
    end
  end

  @doc """
  Calls genserver `:player_leave`
  """
  def player_leave(game_id, player_id) do
    game_id
    |> find_game!()
    |> GenServer.call({:player_leave, player_id})
  end

  def has_player?(game_id, player_id) do
    game_id
    |> find_game!()
    |> GenServer.call({:has_player, player_id})
  end

  @doc """
  Calls genserver `:get_state`
  """
  def get_state(game_id) do
    game_id
    |> find_game!()
    |> GenServer.call(:get_state)
  end

  @doc """
  Calls genserver `:get_player_state` and passes in player_id.
  """
  def get_player_state(game_id, player_id) do
    game_id
    |> find_game!()
    |> GenServer.call({:get_player_state, player_id})
  end

  @doc """
  Calls genserver `:handle_command` and passes in player_id.
  """
  def handle_command(game_id, command, player_id) do
    game_id
    |> find_game!()
    |> GenServer.call({:handle_command, command, player_id})
  end

  def handle_call(:id, _from, state) do
    state.id
  end

  @doc """
  Handle's `:player_leave` by removing the player's data.
  """
  def handle_call({:player_leave, p_id}, _from, state) do
    new_players = Map.delete(state.players, p_id)
  
    state = %{state | players: new_players}

    if length(Map.keys(state.players)) == 0 do
      {:stop, :normal, :no_players, state}
    else
      {:reply, state, state}
    end 
  end

  def handle_info(:update, state) do
    schedule_updates()
    
    IO.puts "updates"
    GameChannel.broadcast_game_update(
      state.game_id,
      %{
        players: state.players,
        balls: state.balls
      }
    )

    {:noreply, state}
  end

  @doc """
  Returns whether or not 
  """
  def handle_call({:has_player, player_id}, _from, state) do
    {:reply, Map.has_key?(state.players, player_id), state}
  end

  @doc """
    Handle's `:get_state` by returning the state.
  """
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @doc """
    Handle's `:get_player_state` by returning the Player struct.
  """
  def handle_call({:get_player_state, p_id}, _from, state) do
    {:reply, Map.get(state.players, p_id), state}
  end

  @doc """
  Handles a user command by updating the user state and in the game state.
  Supports `left`, `right`, `rotate_left`, `rotate_right`.
  """
  def handle_call({:handle_command, command, player_id}, _from, state) do
    player = Map.get(state.players, player_id)

    case command do
      :left -> 
        update_player_state(&Player.move_left/1, state, player)

      :right ->
        update_player_state(&Player.move_right/1, state, player)

      :rotate_left -> 
        update_player_state(&Player.rotate_left/1, state, player)

      :rotate_right -> 
        update_player_state(&Player.rotate_right/1, state, player)
    end
  end

  defp update_player_state(state, player) do
    new_players = Map.replace!(state.players, player.id, player)

    state = %{state | players: new_players}
  
    {:reply, state, state}
  end

  defp update_player_state(command, state, player) do
    updated_player = command.(player)

    update_player_state(state, updated_player)
  end

  defp update_rate do
    round(1_000 / @refresh_rate)  
  end

  @spec config(atom()) :: term
  defp config(key) do
    Application.get_env(:ping, Ping, [])[key]
  end
end
