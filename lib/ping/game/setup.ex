defmodule Ping.Game.Setup do
  @moduledoc """
  Big thanks to Darkash for providing the naming
  used to describe the vectors!

  Actually so good without it I would be stuck
  staring at my code wondering why it was so bad.
  (I still am but to a lesser degree).
  """
  alias Ping.Game.{Player, Wall, Ball, Vector}

  defp wall_size do
    config(:wall_size)
  end

  defp walls do
    config(:walls)
  end

  defp get_field_center do
    x0 = round wall_size() + wall_size() * :math.cos(-1 * 2 * :math.pi / walls())
    y0 = round wall_size() + wall_size() * :math.sin(-1 * 2 * :math.pi / walls())
    x1 = round wall_size() + wall_size() * :math.cos((-1 + (walls() / 2)) * 2 * :math.pi / walls())
    y1 = round wall_size() + wall_size() * :math.sin((-1 + (walls() / 2)) * 2 * :math.pi / walls())

    mid_x = round (x0 + x1) / 2
    mid_y = round (y0 + y1) / 2

    {mid_x, mid_y}
  end

  defp get_wall_centripetal_vector(x0, y0, x1, y1) do
    {center_x, center_y} = get_field_center()

    mid_x = round (x0 + x1) / 2
    mid_y = round (y0 + y1) / 2

    x_change = center_x - mid_x
    y_change = center_y - mid_y
    IO.inspect {x_change, y_change}, label: :get_wall_centripetal_vector

    normalize_vals(x_change, y_change)
  end

  defp get_wall_positions(i) do
    x0 = round wall_size() + wall_size() * :math.cos((i - 1) * 2 * :math.pi / walls())
    y0 = round wall_size() + wall_size() * :math.sin((i - 1) * 2 * :math.pi / walls())
    x1 = round wall_size() + wall_size() * :math.cos(i * 2 * :math.pi / walls())
    y1 = round wall_size() + wall_size() * :math.sin(i * 2 * :math.pi / walls())

    {x0, y0, x1, y1}
  end

  defp normalize_vals(a, b) do
    max_val = max(abs(a), abs(b))

    a_normalized = a / max_val
    b_normalized = b / max_val

    {a_normalized, b_normalized}
  end

  def get_wall_edge_vector(x0, y0, x1, y1) do
    x_change = x0 - x1
    y_change = y0 - y1

    normalize_vals(x_change, y_change)
  end

  def get_wall_edge_vector(index) do
    {x0, y0, x1, y1} = get_wall_positions(index)

    get_wall_edge_vector(x0, y0, x1, y1)
  end

  def gen_game_walls do
    Enum.map(0..walls(), fn(i) ->
      {x0, y0, x1, y1} = get_wall_positions(i)
      {vx, vy} = get_wall_centripetal_vector(x0, y0, x1, y1)

      Wall.new_wall(x0, y0, x1, y1, vx, vy, i)
    end)
  end

  def gen_game_players(players) do
    Enum.with_index(players)
    |> Enum.reduce(%{}, fn {{id, name}, i}, %{} = m ->
      index = i + 2
      {x0, y0, x1, y1} = get_wall_positions(index)

      {vx, vy} = get_wall_centripetal_vector(x0, y0, x1, y1)

      mid_x = round (x0 + x1) / 2 + (25 * vx)
      mid_y = round (y0 + y1) / 2 + (25 * vy)

      {edge_vx, edge_vy} = get_wall_edge_vector(x0, y0, x1, y1)

      x_offset = (Player.width / 2) * edge_vx
      y_offset = (Player.height / 2) * edge_vy

      x0 = round mid_x - x_offset
      y0 = round mid_y - y_offset
      x1 = round mid_x + x_offset
      y1 = round mid_y + y_offset

      player = Player.new_player(x0, y0, x1, y1, name, index, %Vector{x: vx, y: vy})
      Map.put(m, id, player)
    end)
  end

  def gen_game_ball do
    {x, y} = get_field_center()
    %{aaa: Ball.new_ball(x, y, :rand.uniform() * 2 - 1, :rand.uniform() * 2 - 1)}
  end

  @spec config(atom()) :: term
  defp config(key) do
    Application.get_env(:ping, Ping.Game, [])[key]
  end
end
