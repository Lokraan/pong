
defmodule PongWeb.PageController do
  use PongWeb, :controller

  plug :require_user, when action not in [:index]
  
  def index(conn, %{"user" => %{"username" => username}}) do
    render conn, "index.html"
    |> put_session(:user_name, username)
    |> redirect(to: "/lobby/lobby:find_lobby")
  end

  def game(conn, %{"game_id" => game_id}) do
    render conn, "game.html", game_id
  end

  defp require_user(conn, _) do
    if user_id = get_session(conn, :user_id) do
      conn
      |> assign(:user_id, user_id)
      |> assign(:user_token, 
        Phoenix.Token.sign(conn, "user token", user_id))
    else
      conn
      |> put_flash(:error, "Create user to play!")
      |> render("index.html")
      |> halt()
    end
  end

end
