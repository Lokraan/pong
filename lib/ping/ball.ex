defmodule Ping.Ball do
  alias __MODULE__

  @derive Jason.Encoder
  defstruct(
    x_pos: 0,
    y_pos: 0,
    x_vel: 0,
    y_vel: 0
  )

  def step(ball) do
    %Ball{
      x_pos: ball.x_pos + ball.x_vel,
      y_pos: ball.y_pos + ball.y_vel,
      x_vel: ball.x_vel,
      y_vel: ball.y_vel
    }
  end
end
