
defmodule Pong.Player do
 
  alias __MODULE__

  # x_pos and y_pos are overwritten when sent to clients for update
  @enforce_keys [:user_id, :username]
  defstruct (
    id: :string,
    name: :string,
    x_pos: 0,
    y_pos: 0,
    wall_pos: 0
  )

  # method to move/rotate_left/right then method to get camera pos
  def move_left(player) do
    :noop
  end

  def move_right(player) do
    :noop
  end

 def rotate_left(player) do
    :noop
  end
  
  def rotate_right(player) do
    :noop
  end 

end
