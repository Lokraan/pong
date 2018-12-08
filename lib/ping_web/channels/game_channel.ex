defmodule PingWeb.GameChannel do
  use PingWeb, :channel

  alias Ping.Game

  def broadcast_player_update_from(pid, game_id, user_id, player) do
    PingWeb.Endpoint.broadcast_from!(pid, game_id,
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

  def handle_in("command", %{"command" => command}, socket) do
    Game.handle_command("command", socket.assigns.game_id, socket.assigns.user_id)
  end
end
