defmodule PingWeb.PageController do
  use PingWeb, :controller

  plug :require_user when action not in [:index, :play]
 
  def index(conn, _) do
    render(conn, "index.html")
  end

  def play(conn, %{"user" => %{"username" => username}}) do
    conn
    |> put_session(:username, username)
    |> redirect(to: "/find_game")
  end

  def game(conn, %{"game_id" => game_id}) do
    render(conn, "game.html", game_id: game_id)
  end

  def find_game(conn, _params) do
    PingWeb.Endpoint.broadcast!("/socket", "lobby:find", %{})
    render(conn, "lobby.html")
  end

  defp require_user(conn, _) do
    if username = get_session(conn, :username) do
      conn
      |> assign(:username, username)
      |> assign(:user_token, Phoenix.Token.sign(conn, "user token", username))
    else
      conn
      |> put_flash(:error, "Create user to play!")
      |> render("index.html")
      |> halt()
    end
  end
end
