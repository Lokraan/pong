defmodule Ping.Game.Wall do
  alias __MODULE__
  alias Ping.Game.Vector

  @derive Jason.Encoder
  defstruct(
    x0: 0,
    y0: 0,
    x1: 0,
    y1: 0,
    vector: %Vector{}
  )

  def new_wall(x0, y0, x1, y1, vx, vy) do
    %Wall{
      x0: x0,
      y0: y0,
      x1: x1,
      y1: y1,
      vector: %Vector{
        x: vx,
        y: vy
      }
    }
  end
end
