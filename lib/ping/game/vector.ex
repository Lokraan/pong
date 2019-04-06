defmodule Ping.Game.Vector do
  alias __MODULE__

  @derive Jason.Encoder
  defstruct(
    x: 0,
    y: 0
  )

  def dot_product(%Vector{} = v1, %Vector{} = v2) do
    (v1.x * v2.x) + (v1.y * v2.y)
  end

  def magnitude(%Vector{} = v) do
    :math.sqrt((v.x * v.x) + (v.y * v.y))
  end

  def normalize(%Vector{} = v) do
    magnitude = Vector.magnitude(v)

    %Vector{
      x: v.x / magnitude,
      y: v.y / magnitude
    }
  end

  @doc """
    R = v1 - (2 * v2 * dot_product(v1, v2))
  """
  def reflect(%Vector{} = v1, %Vector{} = v2) do
    dp = dot_product(v1, v2)

    r = %Vector{
      x: v1.x - (2.0 * v2.x * dp),
      y: v1.y - (2.0 * v2.y * dp)
    }

    Vector.normalize(r)
  end
end
