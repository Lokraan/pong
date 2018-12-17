defmodule PingWeb.UserSocketTest do
  use PingWeb.ChannelCase, async: true
  alias PingWeb.UserSocket

  test "authenticate with valid token" do
    user_id = 503
    token = Phoenix.Token.sign(@endpoint, "user token", user_id)

    params = %{
      "token" => token,
      "username" => 1,
      "user_id" => user_id,
      "game_id" => 1
    }
    assert {:ok, socket} = connect(UserSocket, params)
    assert socket.assigns.user_id == user_id
  end

  test "authenticate with invalid token" do
    params = %{
      "token" => "invalid-token",
      "username" => 1,
      "user_id" => 1,
      "game_id" => 1
    }

    assert :error = connect(UserSocket, params)
  end
end
