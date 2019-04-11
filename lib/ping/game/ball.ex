defmodule Ping.Game.Ball do
  alias __MODULE__
  alias Ping.Game.Vector

  @derive Jason.Encoder
  defstruct(
    x: 0,
    y: 0,
    vector: %Vector{},
    radius: 10,
    bounces: 0
  )

  def new_ball(x, y, vx, vy) do
    %Ball{
      x: x,
      y: y,
      vector: %Vector{
        x: vx,
        y: vy
      }
    }
  end

  defp speed(ball) do
    speed = :math.sqrt(ball.bounces + 1)

    thresh = :math.floor(ball.radius - :math.sqrt(ball.radius))
    if speed > thresh, do: thresh, else: speed
  end

  def update(ball) do
    x_change = ball.vector.x * speed(ball)
    y_change = ball.vector.y * speed(ball)

    ball
    |> Map.replace!(:x, ball.x + x_change)
    |> Map.replace!(:y, ball.y + y_change)
  end
end
