defmodule Ping.Player do
  alias __MODULE__

  @derive Jason.Encoder
  
  @enforce_keys [:username]
  defstruct(
    username: :string,
    x_pos: 0,
    y_pos: 0,
    camera_x: 0,
    camera_y: 0,
    wall_pos: 0
  )

  # method to move/rotate_left/right then method to get camera pos
  def move_right(player) do
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
end
