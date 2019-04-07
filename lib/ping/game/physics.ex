defmodule Ping.Game.Physics do
  alias Ping.Game.{Ball, Vector}

  @radius_buffer 0

  defp radius_buffer do
    @radius_buffer
  end

  defp dist(x0, y0, x1, y1) do
    dx = x0 - x1
    dy = y0 - y1

    :math.sqrt((dx * dx) + (dy * dy))
  end

  defp point_circle(px, py, cx, cy, r) do
    distance = dist(px, py, cx, cy)

    distance <= (r + radius_buffer())
  end

  defp line_point(x0, y0, x1, y1, px, py) do
    d1 = dist(px, py, x0, y0)
    d2 = dist(px, py, x1, y1)

    line_len = dist(x0, y0, x1, y1)
    buffer = 0

    (d1 + d2 >= line_len - buffer) and (d1 + d2 <= line_len + buffer)
  end

  defp get_circle_dist(%Ball{} = b, w) do
    dx = w.x0 - w.x1
      dy = w.y0 - w.y1

      len = :math.sqrt((dx * dx) + (dy * dy))
      dot =
        (((b.x - w.x0) * (w.x1 - w.x0))  + ((b.y - w.y0) * (w.y1 - w.y0))) / (len * len)

      closest_x = w.x0 + (dot * (w.x1 - w.x0))
      closest_y = w.y0 + (dot * (w.y1 - w.y0))

      on_segment? = line_point(w.x0, w.y0, w.x1, w.y1, closest_x, closest_y)

      if on_segment? do
        {:ok, dist(closest_x, closest_y, b.x, b.y)}
      else
        {:error, :nil}
      end
  end

  def circle_collide_with_line?(%Ball{} = b, w) do
    inside1 = point_circle(w.x0, w.y0, b.x, b.y, b.radius)
    inside2 = point_circle(w.x1, w.y1, b.x, b.y, b.radius)

    if inside1 or inside2 do
      true
    else
      dist = get_circle_dist(b, w)

      case dist do
        {:ok, d} ->
          d <= (b.radius + radius_buffer())

        _ ->
          false
      end
    end
  end

  def wall_ball_collision(%Ball{} = b, w) do
    {:ok, dist} = get_circle_dist(b, w)
    d = dist + :math.sqrt(b.radius)

    v = Vector.reflect(b.vector, w.reflection_vector)

    b =
      b
      |> Map.replace!(:vector, v)
      |> Map.update!(:x, &(&1 + v.x * d))
      |> Map.update!(:y, &(&1 + v.y * d))

    {b, w}
  end
end
