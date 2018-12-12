defmodule PingWeb.UserSocket do
  use Phoenix.Socket

  ## Channels
  channel "lobby:*", PingWeb.LobbyChannel
  channel "game:*", PingWeb.GameChannel

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  def connect(%{"token" => token, 
      "username" => username, 
      "user_id" => user_id, 
      "game_id" => game_id
      }, socket, connect_info) do
    case Phoenix.Token.verify(socket, "user token", token, max_age: 86400) do
      {:ok, username} ->
        socket = 
          socket
          |> assign(:username, username)
          |> assign(:user_id, user_id)
          |> assign(:game_id, game_id)

        {:ok, socket}

      {:error, _reason} ->
        :error
    end
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     PingWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(socket), do: "user_socket:#{socket.assigns.user_id}"

  defp gen_id do
    :crypto.strong_rand_bytes(8)
    |> Base.url_encode64()
    |> binary_part(0, 8)
  end
end
