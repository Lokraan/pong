defmodule Ping.Game.Setup do
  @moduledoc """
  Big thanks to Darkash for providing the naming
  used to describe the vectors!

  Actually so good without it I would be stuck
  staring at my code wondering why it was so bad.
  (I still am but to a lesser degree).
  """

  alias Ping.Game.{Wall, Vector}

  def wall_centripetal_vectors do
    %{
      0 => {1, 1},
      1 => {-1, 0},
      2 => {1, -1},
      3 => {1, 1},
      4 => {1, 0},
      5 => {0, 1}
    }
  end

  defp wall_size do
    config(:wall_size)
  end

  defp walls do
    config(:walls)
  end

  defp get_wall_positions(i) do
    x0 = round wall_size + wall_size * :math.cos((i - 1) * 2 * :math.pi / walls) 
    y0 = round wall_size + wall_size * :math.sin((i - 1) * 2 * :math.pi / walls)
    x1 = round wall_size + wall_size * :math.cos(i * 2 * :math.pi / walls)
    y1 = round wall_size + wall_size * :math.sin(i * 2 * :math.pi / walls)

    {x0, y0, x1, y1}
  end

  def get_wall_edge_vector(i) do
    vx = :math.cos(i * 2 * :math.pi / walls)
    vy = :math.sin(i * 2 * :math.pi / walls)

    %Vector{
      x: vx,
      y: vy
    }
  end

  def gen_game_walls do
    Enum.map(0..5, fn(i) ->
      {vx, vy} = Map.get(wall_centriptal_vectors, i)

      {x0, y0, x1, y1} = get_wall_pos(i)

      Wall.new_wall(x0, y0, x1, y1, vx, vy)
    end)
  end

  def gen_game_players(players) do
    m = %{}
    Enum.with_index(players)
    |> Enum.reduce(%{}, fn {{id, name}, index}, m ->
      {x0, y0, x1, y1} = get_wall_pos(index)
      {vx, vy} = Map.get(wall_centripetal_vectors, index)

      ang = 
        cond do
          vx == 0 and vy > 0 ->
            1.5707963267948966

          vx == 0 and vy < 0 ->
            -1.5707963267948966

          true ->  
            :math.atan(vy / vx)
        end

      x = (x0 + x1) / 2 + 100 * :math.cos(ang)
      y = (y0 + y1) / 2 + 100 * :math.sin(ang)

      x_offset = (Player.width / 2) * :math.cos(ang)
      y_offset = (Player.height / 2) * :math.sin(ang) 

      x0 = round x - x_offset
      y0 = round y - y_offset
      x1 = round x + x_offset
      y1 = round y + y_offset

      player = Player.new_player(x0, y0, x1, y1, name, index)
      Map.put(m, id, player)
    end)
  end

  @spec config(atom()) :: term
  defp config(key) do
    Application.get_env(:ping, Ping, [])[key]
  end
end
