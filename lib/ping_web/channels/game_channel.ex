defmodule PingWeb.GameChannel do
  use PingWeb, :channel

  alias Ping.{Game, GameSupervisor}

  def broadcast_game_update(game_id, data) do
    PingWeb.Endpoint.broadcast!(topic(game_id), "game:update", data)
  end

  def broadcast_game_end(game_pid, game_id, players) do
    PingWeb.Endpoint.broadcast!(topic(game_id), "game:end", players)

    DynamicSupervisor.terminate_child(GameSupervisor, game_pid)
  end

  def join("game:" <> _game_id, _params, socket) do
    {:ok, socket}
  end

  def handle_in("game:command", %{"command" => command, "type" => type}, socket) do
    Game.handle_command(socket.assigns.game_id, command, type, socket.assigns.user_id)

    {:reply, :ok, socket}
  end

  @doc """
  Handles a player's leave.
  """
  def handle_in("game:leave", _, socket) do
    game_id = socket.assigns.game_id
    user_id = socket.assigns.user_id

    Game.player_leave(game_id, user_id)

    {:reply, {:ok, %{}}, socket}
  end

  defp topic(game_id) do
    "game:#{game_id}"
  end
end
