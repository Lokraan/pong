defmodule Ping.Player do
  alias __MODULE__

  # x_pos and y_pos are overwritten when sent to clients for update
  @enforce_keys [:user_id, :username]

  alias __MODULE__
  defstruct(
    user_id: :string,
    username: :string,
    x_pos: 0,
    y_pos: 0,
    camera_x: 0,
    camera_y: 0,
    wall_pos: 0
  )

  # method to move/rotate_left/right then method to get camera pos
  def move_right(player) do
    :noop
  end

  def move_left(player) do
    :noop
  end

  def rotate_right(player) do
    :noop
  end
  
  def rotate_left(player) do
    :noop
  end
end
