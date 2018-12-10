defmodule PingWeb.LobbyChannelTest do
  use PingWeb.ChannelCase, async: true

  import Phoenix.Socket

  alias PingWeb.LobbyChannel
  alias PingWeb.UserSocket

  describe "Test lobby channel" do
    setup do
      user_id = 503
      token = Phoenix.Token.sign(@endpoint, "user token", user_id)

      {:ok, socket} = connect(UserSocket, %{"token" => token})
      socket = assign(socket, :username, "hello")
      
      {:ok, socket: socket}
    end

    test "user joins `lobby:find` succesfully and another channel succesfully", %{socket: socket} do
      assert {:ok, lobby_id} = LobbyChannel.join("lobby:find", %{}, socket)
      IO.inspect lobby_id, label: :test 

      assert {:ok, lobby_id} = LobbyChannel.join("lobby:#{lobby_id}", %{}, socket)
    end
  end
end
