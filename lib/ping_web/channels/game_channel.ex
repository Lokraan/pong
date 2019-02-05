defmodule PingWeb.GameChannel do
  use PingWeb, :channel

  alias Ping.Game

  def broadcast_game_update(game_id, data) do
    PingWeb.Endpoint.broadcast!(topic(game_id), "game:update", data)
  end

  def join("game:" <> game_id, _params, socket) do
    {:ok, :joined, socket}
  end

  def handle_in("game:command", %{"command" => command, "type" => type}, socket) do
    Game.handle_command(socket.assigns.game_id, command, type, socket.assigns.user_id)
  end

    @doc """
  Handles a player's leave.
  """
  def handle_in("game:leave", _, socket) do
    game_id = socket.assigns.game_id
    user_id = socket.assigns.user_id

    if Game.player_leave(game_id, user_id) == :no_players do
      PingWeb.Endpoint.broadcast!(topic(game_id), "game:end", %{})
    end

    {:reply, {:ok, %{}}, socket}
  end

  defp topic(game_id) do
    "game:#{game_id}"
  end
end
