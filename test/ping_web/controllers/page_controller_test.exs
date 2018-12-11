defmodule PingWeb.PageControllerTest do
  use PingWeb.ConnCase

  import Phoenix.ChannelTest, only: [assert_broadcast: 3]

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) != ""
  end

  test "GET /find_game", %{conn: conn} do
    @endpoint.subscribe("/socket")
    
    PingWeb.Endpoint.broadcast!("/socket", "lobby:find", %{})

    assert_broadcast("lobby:find", %{}, 100)
  end
end
