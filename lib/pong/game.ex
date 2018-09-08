
# Server side detection
# Camera concept
# Only start game when all clients signal OK

defmodule Pong.Game do
  @moduledoc """
    This module is the Game module which handles all updates for
  the game it is assigned to.

    Game also has a default struct where the keys `:game_id` and
  `:players` are enforced.
  `defstruct(
    id: :string,
    players: %{},
    balls: %{},
    max_players: 6
    )`
  """

  use GenServer

  alias Pong.{GameState, Player, Ball}
  alias __MODULE__

  @enforce_keys [:game_id, :players]
  defstruct(
    id: :string,
    players: %{},
    balls: %{},
    max_players: 6
  )


  @doc """
    The start_link modules, expects `opts` to be passed into
  it and expects opts to contain `:game_id` and `:players`

  ## Examples
    
    DynamicSupervisor.start_child(Pong.GameSupervisor, {
      Pong.Game, game_id: game_id, players: players
    })

  """
  def start_link(opts) do
    game_id = Keyword.fetch!(opts, :game_id)
    player_data = Keyword.fetch!(opts, :players)

    players = for data <- player_data, do: 
      %Player{data.user_id, data.username}
    end

    GenServer.start_link(__MODULE__, [game_id, players],
      name: {:via, Registry, {Pong.GameRegistry, game_id}}
    )
  end

  @doc """
    Initiator of the genserver, creates the state by setting the
    `:game_id` and `:players` tags.

    ## Examples
      GenServer.start_link(__MODULE__, [game_id, players],
        name: {:via, Registry, {Pong.GameRegistry, game_id}}
      )
  """
  def init([game_id, players]) do
    IO.puts "Init game_id: #{game_id}"
    state = %Game{game_id: game_id, players: players}

    {:ok, state}
  end


  @doc """
    Finds the game's PID based on it's id by searching in the
  `Pad.GameRegistry` Didn't store the pid w/ socket.assigns,
  sorry cjfreeze.
  """
  def find_game!(game_id) do
    case Registry.lookup(Pad.GameRegistry, game_id) do
      [{pid, _}] ->
        pid
      [] ->
        raise ArgumentError, "Game not found for id #{game_id}"
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
    Calls genserver `:move_right` and passes in player_id.
  """
  def move_right(game_id, player_id) do
    game_id
    |> find_game!()
    |> GenServer.call({:move_right, player_id})
  end

  @doc """
    Calls genserver `:move_left` and passes in player_id.
  """
  def move_left(game_id, player_id) do
    game_id
    |> find_game!()
    |> GenServer.call({:move_left, player_id})
  end

  @doc """
    Calls genserver `:rotate_right` and passes in player_id.
  """
  def rotate_right(game_id, player_id) do
    game_id
    |> find_game!()
    |> GenServer.call({:rotate_right, player_id})
  end

  @doc """
    Calls genserver `:rotate_left` and passes in player_id.
  """
  def rotate_left(game_id, p_id) do
    game_id
    |> find_game!()
    |> GenServer.call({:rotate_left, p_id})
  end

  @doc """
    Handle's `:player_leave` by removing the player's data.
  """
  def handle_call({:player_leave, p_id}) do
    new_players = Map.remove(state.players, p_id)
  
    {:noreply, {state | players: new_players}}
  end

  @doc """
    Handle's `:get_state` by returning the state.
  """
  def handle_call(:get_state) do
    {:reply, state, state}
  end

  @doc """
    Handle's `:get_player_state` by returning the Player struct.
  """
  def handle_call({:get_player_state, p_id}) do
    {:reply, Map.get(state.players, p_id), state}
  end

  @doc """
    Private method for updating the players map in the Game State.
  """
  defp update_player_state(player_state, player) do
    new_players = Map.replace!(state.players, player.id, player)

    new_state = %{state | players: new_players}}
  end

  @doc """
    Handle's `:move_right` by getting the Player struct that
    corresponds to `p_id`
  """
  def handle_call({:move_right, p_id}) do
    player = Map.get(state.players, p_id)

    moved_player = Player.move_right(player)
    new_state = update_player_state(state.players, moved_player)

    {:reply, moved_player, new_state}
  end

  def handle_call({:move_left, player_id}) do
    player = Map.get(state.players, p_id)

    moved_player = Player.move_left(player)
    new_state = update_player_state(state.players, moved_player)

    {:reply, moved_player, new_state}
  end

  def handle_call({:rotate_right, player_id}) do
    player = Map.get(state.players, p_id)

    moved_player = Player.rotate_right(player)
    new_state = update_player_state(state.players, moved_player)

    {:reply, moved_player, new_state}
  end

  def handle_call({:rotate_left, player_id}) do
    player = Map.get(state.players, p_id)

    moved_player = Player.rotate_left(player)
    new_state = update_player_state(state.players, moved_player)

    {:reply, moved_player, new_state}
  end

end
