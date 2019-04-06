defmodule Ping.Game.Player do
  alias __MODULE__
  alias Ping.Game.{Vector, Setup}

  @derive Jason.Encoder
  
  @enforce_keys [:username, :wall_index]
  defstruct(
    username: :string,
    x0: 0,
    y0: 0,
    x1: 0,
    y1: 0,
    vector: %Vector{},
    reflection_vector: %Vector{},
    wall_index: 0
  )

  @width 25
  @height 25

  def new_player(x0, y0, x1, y1, username, wall_index, reflection_vector) do
    %Player{
      username: username,
      x0: x0,
      y0: y0,
      x1: x1,
      y1: y1,
      wall_index: wall_index,
      reflection_vector: reflection_vector
    }
  end

  def player_speed do
    2.5
  end

  defp update_player_vector(player, vx, vy) do
    new_v = %Vector{
      x: vx,
      y: vy
    }

    Map.replace!(player, :vector, new_v)
  end

  def stop(player) do
    update_player_vector(player, 0, 0)
  end

  def update(player) do
    %Vector{x: vx, y: vy} = player.vector
    x_change = vx * player_speed()
    y_change = vy * player_speed()

    player
    |> Map.replace!(:x0, player.x0 + x_change)
    |> Map.replace!(:x1, player.x1 + x_change)
    |> Map.replace!(:y0, player.y0 + y_change)
    |> Map.replace!(:y1, player.y1 + y_change)
  end

  # method to move/rotate_left/right then method to get camera pos
  def move_right(player) do
    {vx, vy} = Setup.get_wall_edge_vector(player.wall_index)

    update_player_vector(player, vx, vy)
  end

  def move_left(player) do
    {vx, vy} = Setup.get_wall_edge_vector(player.wall_index)

    update_player_vector(player, -1 * vx, -1 * vy)
  end

  def rotate_right(player) do
    player
  end
  
  def rotate_left(player) do
    player
  end

  def width do
    @width
  end

  def height do
    @height
  end
end
