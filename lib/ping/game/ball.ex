defmodule Ping.Game.Ball do
  alias __MODULE__
  alias Ping.Game.Vector

  @derive Jason.Encoder
  defstruct(
    x: 0,
    y: 0,
    vector: %Vector{},
    radius: 10
  )

  def new_ball(x, y) do
    %Ball{
      x: x,
      y: y,
      vector: %Vector{
        x: 0,
        y: 0
      }
    }
  end

  def step(ball) do
    %Ball{
      x: ball.x + ball.vector.x,
      y: ball.y + ball.vector.y,
    }
  end
end
