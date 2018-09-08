
defmodule PongWeb.GameChannel do
  use PongWeb, :channel

  alias Pong.Game

  def broadcast_player_update_from(pid, game_id, user_id, player) do
    PongWeb.Endpoint.broadcast_from!(pid, game_id,
      "player_update", player)
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
    Game.player_rotate_right(socket.assigns.user_id)
  end

  def handle_in("rotate_left", _, socket) do
    Game.player_rotate_left(socket.assigns.user_id)
  end

  def handle_in("move_right", _, socket) do
    Game.player_move_right(socktet.assigns.user_id)
  end

  def handle_in("move_left", _, socket) do
    Game.player_move_left(socket.assigns.user_id)
  end

end
