defmodule PingWeb.LobbyChannelTest do
  use PingWeb.ChannelCase

  alias PingWeb.LobbyChannel
  alias PingWeb.UserSocket

  describe "lobby channel" do
    setup do
      config = Application.get_env(:ping, Ping)
      user_id = 503
      token = Phoenix.Token.sign(@endpoint, "user token", user_id)

      params = %{
        "token" => token,
        "username" => 1,
        "user_id" => 1,
        "game_id" => 1
      }

      {:ok, socket} = connect(UserSocket, params)
     
      on_exit(fn ->
        Application.put_env(:ping, Ping, config)

        Enum.map(DynamicSupervisor.which_children(Ping.LobbySupervisor), fn p -> 
          {:undefined, pid, _, _} = p
          DynamicSupervisor.terminate_child(Ping.LobbySupervisor, pid)
        end)
      end)

      {:ok, socket: socket}
    end

    test "user joins `lobby:find` succesfully and another channel succesfully", %{socket: socket} do
      assert {:ok, lobby_id, _} = LobbyChannel.join("lobby:find", %{}, socket)

      assert {:ok, _, _} = LobbyChannel.join(lobby_id, %{}, socket)
    end

    test "user joins the same lobby as another user", %{socket: socket} do
      Application.put_env(:ping, Ping, max_players: 2)

      user_id = 504
      token = Phoenix.Token.sign(@endpoint, "user token", user_id)

      params = %{
        "token" => token,
        "username" => 1,
        "user_id" => user_id,
        "game_id" => 1
      }

      {:ok, another_socket} = connect(UserSocket, params)

      assert {:ok, lobby_id, _} = LobbyChannel.join("lobby:find", %{}, socket)
      assert {:ok, _, _} = LobbyChannel.join(lobby_id, %{}, socket)

      assert {:ok, ^lobby_id, _} = LobbyChannel.join("lobby:find", %{}, another_socket)
      assert {:ok, _, _} = LobbyChannel.join(lobby_id, %{}, another_socket)
    end

    test "creates a game once the lobby is full", %{socket: socket} do
      Application.put_env(:ping, Ping, max_players: 1)

      assert {:ok, lobby_id, _} = LobbyChannel.join("lobby:find", %{}, socket)

      @endpoint.subscribe(lobby_id)
      assert {:ok, _, _} = LobbyChannel.join(lobby_id, %{}, socket)

      assert_broadcast("game:start", game_id)
    end

    test "doesn't allow a user to join if the lobby is full", %{socket: socket} do
      Application.put_env(:ping, Ping, max_players: 0)

      assert {:ok, lobby_id, _} = LobbyChannel.join("lobby:find", %{}, socket)

      assert {:error, _} = LobbyChannel.join(lobby_id, %{}, socket)
    end
  end
end
