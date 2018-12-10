defmodule PingWeb.UserSocketTest do
  use PingWeb.ChannelCase, async: true
  alias PingWeb.UserSocket

  test "authenticate with valid token" do
    user_id = 503
    token = Phoenix.Token.sign(@endpoint, "user token", user_id)

    assert {:ok, socket} = connect(UserSocket, %{"token" => token})
    assert socket.assigns.user_id == user_id
  end

  test "authenticate with invalid token" do
    assert :error = connect(UserSocket, %{"token" => "invalid-token"})
  end
end
