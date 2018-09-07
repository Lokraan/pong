
defmodule PongWeb.GameChannel do
  use PongWeb, :channel

  alias Pong.Game

  def broadcast_move_from(pid, game_id, user_id, move) do
    PongWeb.Endpoint.broadcast_from!(pid, game_id, "move", %{
      user_id: user_id,
      move: move
    })
  end

  def join("game:" <> game_id, _params, socket) do
    game_state = Game.get_state(game_id)

    if(Kernel.map_size(game_state.users) > game_state.max_users) do
      {:ok, socket}
    else
      {:error, socket}
    end
  end

  def handle_in("rotate_right", _, socket) do

  end

end
