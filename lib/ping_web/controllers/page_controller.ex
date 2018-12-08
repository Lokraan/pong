defmodule PingWeb.PageController do
  use PingWeb, :controller

  plug :require_user when action not in [:index, :play]
 
  def index(conn, _) do
    render(conn, "index.html")
  end

  def play(conn, %{"user" => %{"username" => username}}) do
    conn
    |> put_session(:user_name, username)
    |> redirect(to: "/lobby/lobby:find_lobby")
  end

  def game(conn, %{"game_id" => game_id}) do
    render(conn, "game.html", game_id: game_id)
  end

  def lobby(conn, %{"lobby_id" => lobby_id}) do
    render(conn, "lobby.html", lobby_id: lobby_id)
  end

  defp require_user(conn, _) do
    if user_name = get_session(conn, :user_name) do
      conn
      |> assign(:user_name, user_name)
      |> assign(:user_token, Phoenix.Token.sign(conn, "user token", user_name))
    else
      conn
      |> put_flash(:error, "Create user to play!")
      |> render("index.html")
      |> halt()
    end
  end
end
