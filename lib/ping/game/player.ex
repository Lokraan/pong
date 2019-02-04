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
    wall_index: 0
  )

  @width 25
  @height 5

  def new_player(x0, y0, x1, y1, username, wall_index) do
    %Player{
      username: username,
      x0: x0,
      y0: y0,
      x1: x1,
      y1: y1,
      wall_index: wall_index
    }
  end

  def pos_change_amt do
    2.5
  end

  # method to move/rotate_left/right then method to get camera pos
  def move_right(player) do
    %Vector{x: vx, y: vy} = Setup.get_wall_vector(player.wall_index)
    x_change = pos_change_amt * vx 
    y_change = pos_change_amt * vy

    player
  end

  def move_left(player) do
    player
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
