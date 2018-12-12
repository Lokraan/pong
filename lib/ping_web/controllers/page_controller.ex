defmodule PingWeb.PageController do
  use PingWeb, :controller

  plug :require_user when action not in [:index, :play]
 
  def index(conn, _) do
    render(conn, "index.html")
  end

  def play(conn, %{"user" => %{"username" => username}}) do
    conn
    |> put_session(:username, username)
    |> put_session(:user_id, gen_id())
    |> redirect(to: "/find_game")
  end

  def game(conn, %{"game_id" => game_id}) do
    case Ping.Game.find_game(game_id) do
      {:ok, _} ->
        conn
        |> put_session(:game_id, game_id)
        |> render("game.html")
      {:error, _} ->
        redirect(conn, to: "/find_game")
    end
  end

  def find_game(conn, _params) do
    render(conn, "lobby.html")
  end

  defp require_user(conn, _) do
    if username = get_session(conn, :username) do
      user_id = get_session(conn, :user_id)
      game_id = get_session(conn, :game_id)
      conn
      |> assign(:username, username)
      |> assign(:user_id, user_id)
      |> assign(:game_id, game_id)
      |> assign(:user_token, Phoenix.Token.sign(conn, "user token", username))
    else
      conn
      |> put_flash(:error, "Create user to play!")
      |> render("index.html")
      |> halt()
    end
  end

  defp gen_id do
    :crypto.strong_rand_bytes(8)
    |> Base.url_encode64()
    |> binary_part(0, 8)
  end
end
