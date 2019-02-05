defmodule Ping.Game.Physics do
  alias Ping.Game.{Ball, Vector}

  def wall_ball_collision?(%Ball{} = b, w) do
    # calc delta distance: source point to line start
    dx = b.x - w.x0
    dy = b.y - w.y0

    # calc delta distance: line start to end
    dxx = w.x1 - w.x0
    dyy = w.y1 - w.y0

    # Calc position on line normalized between 0.00 & 1.00
    # == dot product divided by delta line distances squared
    t = (dx * dxx + dy * dyy) / (dxx * dxx + dyy * dyy)

    # clamp results to being on the segment
    {x, y} = 
      cond do
        t < 0 ->
          {w.x0, w.y0}

        t > 1 ->
          {w.x1, w.y1}
        
        true ->
          # calc nearest pt on line
          {w.x0 + dxx * t, w.y0 + dyy * t}
      end

    {x, y, (t >= 0 and t <= 1)}
  end

  def wall_ball_collision(%Ball{} = b, w) do
    case wall_ball_collision?(b, w) do
      {_, _, true} ->
        v = Vector.reflect(b.vector, w.reflection_vector)
        b = Map.replace!(b, :vector, v)

        {b, w}
      _ ->
        {b, w} 
    end
  end
end
