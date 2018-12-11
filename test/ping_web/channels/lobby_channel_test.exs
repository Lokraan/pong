defmodule PingWeb.LobbyChannelTest do
  use PingWeb.ChannelCase

  import Phoenix.Socket

  alias PingWeb.LobbyChannel
  alias PingWeb.UserSocket

  describe "lobby channel" do
    setup do
      config = Application.get_env(:ping, Ping.Lobby)
      user_id = 503
      token = Phoenix.Token.sign(@endpoint, "user token", user_id)

      {:ok, socket} = connect(UserSocket, %{"token" => token})
      socket = assign(socket, :username, "hello")
     
      on_exit(fn ->
        Application.put_env(:ping, Ping.Lobby, config)

        Enum.map(DynamicSupervisor.which_children(Ping.LobbySupervisor), fn p -> 
          {:undefined, pid, _, _} = p
          DynamicSupervisor.terminate_child(Ping.LobbySupervisor, pid)
        end)
      end)

      {:ok, socket: socket}
    end

    test "user joins `lobby:find` succesfully and another channel succesfully", %{socket: socket} do
      assert {:ok, lobby_id} = LobbyChannel.join("lobby:find", %{}, socket)

      assert {:ok, _} = LobbyChannel.join("lobby:#{lobby_id}", %{}, socket)
    end

    test "user joins the same lobby as another user", %{socket: socket} do
      Application.put_env(:ping, Ping.Lobby, max_players: 2)

      user_id = 504
      token = Phoenix.Token.sign(@endpoint, "user token", user_id)

      {:ok, another_socket} = connect(UserSocket, %{"token" => token})
      another_socket = assign(another_socket, :username, user_id)

      assert {:ok, lobby_id} = LobbyChannel.join("lobby:find", %{}, socket)
      assert {:ok, _} = LobbyChannel.join("lobby:#{lobby_id}", %{}, socket)

      assert {:ok, ^lobby_id} = LobbyChannel.join("lobby:find", %{}, another_socket)
      assert {:ok, _} = LobbyChannel.join("lobby:#{lobby_id}", %{}, another_socket)
    end

    test "creates a game once the lobby is full", %{socket: socket} do
      Application.put_env(:ping, Ping.Lobby, max_players: 1)

      assert {:ok, lobby_id} = LobbyChannel.join("lobby:find", %{}, socket)

      topic = Ping.Lobby.topic(lobby_id)
      @endpoint.subscribe(topic )
      assert {:ok, _} = LobbyChannel.join(topic , %{}, socket)

      assert_broadcast("game:start", game_id)
    end

    test "doesn't allow a user to join if the lobby is full", %{socket: socket} do
      Application.put_env(:ping, Ping.Lobby, max_players: 0)

      assert {:ok, lobby_id} = LobbyChannel.join("lobby:find", %{}, socket)

      topic = Ping.Lobby.topic(lobby_id)
      assert {:error, _} = LobbyChannel.join(topic , %{}, socket)
    end
  end
end
