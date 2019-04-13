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

  alias Ping.Game.{Setup, Engine}
  alias PingWeb.GameChannel

  @refresh_rate 60
  @start_delay 3_000

  @enforce_keys [:game_id, :players, :walls]

  alias __MODULE__
  defstruct(
    game_id: :string,
    players: %{},
    balls: %{},
    walls: [],
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
    p_count = map_size(players)

    walls =
      cond do
        p_count == 2 ->
          4

        rem(p_count, 2) == 1 ->
          p_count * 2

        true ->
          p_count
      end

    state = %Game{
      game_id: game_id,
      players: Setup.gen_game_players(players, walls),
      max_players: config(:max_players) || 6,
      balls: Setup.gen_game_ball(map_size(players), walls),
      walls: Setup.gen_game_walls(walls)
    }

    start()

    {:ok, state}
  end

  defp start_delay do
    @start_delay
  end

  defp start do
    Process.send_after(self(), :update, start_delay())
  end

  defp schedule_updates do
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
  def handle_command(game_id, command, type, player_id) do
    game_id
    |> find_game!()
    |> GenServer.call({:handle_command, command, type, player_id})
  end

  def handle_info(:update, state) do
    {updated_players, updated_balls} = Engine.get_game_updates(state)

    state =
      state
      |> Map.replace!(:players, updated_players)
      |> Map.replace!(:balls, updated_balls)

    GameChannel.broadcast_game_update(
      state.game_id,
      %{
        players: state.players,
        balls: state.balls,
        walls: state.walls
      }
    )

    if map_size(state.players) > 1 do
      schedule_updates()

      {:noreply, state}
    else
      GameChannel.broadcast_game_end(self(), state.game_id, state.players)

      {:noreply, state}
    end
  end

  @doc """
  Handle's `:player_leave` by removing the player's data.
  """
  def handle_info({:player_leave, p_id}, _from, state) do
    new_players = Map.delete(state.players, p_id)

    state = %{state | players: new_players}

    if map_size(state.players) == 1 do
      GameChannel.broadcast_game_end(self(), state.game_id, state.players)

      {:noreply, state}
    else
      {:noreply, state}
    end
  end

  def handle_call(:id, _from, state) do
    state.id
  end

  def handle_call({:has_player, player_id}, _from, state) do
    {:reply, Map.has_key?(state.players, player_id), state}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:get_player_state, p_id}, _from, state) do
    {:reply, Map.get(state.players, p_id), state}
  end

  def handle_call({:handle_command, command, type, player_id}, _from, state) do
    Engine.handle_player_command(command, type, player_id, state)
  end

  defp refresh_rate do
    @refresh_rate
  end

  defp update_rate do
    round(1_000 / refresh_rate())
  end

  @spec config(atom()) :: term
  defp config(key) do
    Application.get_env(:ping, Ping, [])[key]
  end
end
