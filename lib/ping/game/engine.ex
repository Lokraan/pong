defmodule Ping.Game.Engine do
  alias Ping.Game.{Ball, Physics, Player}

  defp update_players(players) do
    Enum.reduce(players, %{}, fn {id, %Player{} = player}, %{} = m ->
      new_player = Player.update(player)

      Map.put(m, id, new_player)
    end)
  end

  defp get_ball_wall_collisions(ball, walls) do
    wall_collisions = Enum.filter(walls, fn w ->
        Physics.circle_collide_with_line?(ball, w)
    end)

    case wall_collisions do
      [w] ->
        {b, _w} = Physics.wall_ball_collision(ball, w)
        new_ball = Map.replace!(b, :bounces, b.bounces + 1)


        {:collision, new_ball, w.index}

      _ ->
        {:no_collision}
    end
  end

  defp get_ball_player_collisions(ball, players) do
    player_collisions = Enum.filter(players, fn {_id, p} ->
      Physics.circle_collide_with_line?(ball, p)
    end)

    case player_collisions do
      [{_id, p}] ->
        {b, _} = Physics.wall_ball_collision(ball, p)
        new_ball = Map.replace!(b, :bounces, b.bounces + 1)

        {:collision, new_ball}

      _ ->
        {:no_collision}
    end
  end

  defp process_ball_collisions(ball, wall_collisions, player_collisions) do
    cond do
      :collision == elem(wall_collisions, 0) ->
        {:collision, w_ball, index} = wall_collisions
        {w_ball, [index]}

      :collision == elem(player_collisions, 0) ->
        {:collision, p_ball} = player_collisions
        {p_ball, []}

      true ->
        {ball, []}
    end
  end

  defp get_ball_update_info(balls, walls, players) do
    Enum.reduce(balls, %{}, fn {id, %Ball{} = ball}, %{} = m ->
      ball_wall_collisions = get_ball_wall_collisions(ball, walls)
      ball_player_collisions = get_ball_player_collisions(ball, players)
    
      {new_ball, out_players} = 
        process_ball_collisions(ball, ball_wall_collisions, ball_player_collisions)

      m
      |> Map.put(id, new_ball)
      |> Map.update(:out_players, out_players, &(&1 ++ out_players))
    end)
  end

  defp update_balls(balls) do
    Enum.reduce(balls, %{}, fn {id, %Ball{} = ball}, %{} = m ->
      new_ball = Ball.update(ball)

      Map.put(m, id, new_ball)
    end)
  end

  def get_out_players(players, out_players) do
    Enum.filter(players, fn {_id, p} ->
      Enum.member?(out_players, p.wall_index)
    end)
  end

  def get_game_updates(game) do
    updated_players = update_players(game.players)
    ball_update_info = get_ball_update_info(game.balls, game.walls, game.players)

    updated_balls = 
      ball_update_info
      |> Map.delete(:out_players)
      |> update_balls()

    out_players = get_out_players(updated_players, Map.get(ball_update_info, :out_players))

    {updated_players, updated_balls, out_players}
  end

  def handle_player_command(command, type, player_id, state) do
    player = Map.get(state.players, player_id)

    cmd = cond do
      type == "press" ->
        case command do
          "move_left" -> 
            &Player.move_left/1

          "move_right" ->
            &Player.move_right/1

          "rotate_left" -> 
            &Player.rotate_left/1

          "rotate_right" -> 
            &Player.rotate_right/1
        end
      type == "release" ->
        &Player.stop/1
    end

    update_player_state(cmd, state, player, player_id)
  end

  defp update_player_state(state, player, player_id) do
    new_players = Map.replace!(state.players, player_id, player)
    new_state = Map.replace!(state, :players, new_players)

    {:reply, new_state, new_state}
  end

  defp update_player_state(command, state, player, player_id) do
    updated_player = command.(player)

    update_player_state(state, updated_player, player_id)
  end
end
