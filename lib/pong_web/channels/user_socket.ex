defmodule PongWeb.UserSocket do
  use Phoenix.Socket

  ## Channels
  # channel "room:*", PongWeb.RoomChannel
  channel "game:*", PadWeb.GameChannel
  channel "lobby:*", PadWeb.LobbyChanel

  def connect(%{"token" => token}, socket, _connect_info) do
    case Phoenix.Token.verify(socket, "user token", token, max_age: 86400) do
      {:ok, user_id} ->
        {:ok, assign(socket, :user_id, user_id)}

      {:error, reason} ->
        Logger.error(fn -> "failed to verify: #{IO.inspect reason}" end)
        :error
    end
  end

  def id(socket), do: "user_socket:#{socket.assigns.user_id}"

end
