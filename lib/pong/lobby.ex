
defmodule Pong.Lobby do
  use GenServer

  alias Pong.Lobby

  def start_link(opts) do
    lobby_id = Keyword.fetch!(opts, :lobby_id)

    GenServer.start_link(__MODULE__, [lobby_id],
      name: {:via, Registry, {Pong.Registry, get_pid(lobby_id)}}
      )
  end

  def init([lobby_id]) do
    IO.puts "Init lobby_id: #{lobby_id}"
    state = %{
      lobby_id: lobby_id,
      players: %{},
      max_players: 6
    }
  end

  def get_lobby() do
    case Registry.keys(Pong.Supervisor, self()) do
      [first | rest] -> 
        IO.inspect [first | rest] label: "Lobbies: "
      _ ->
        IO.inspect :nil label: "Lobbies: "
        :nil
    end
  end

  defp get_pid(lobby_id), do: "lobby:#{lobby_id}"

  def add_player(player) do
    new_state = %{state | 
      players: Map.put(state.players, player.id, player)}
    {:reply, new_state, new_state}
  end

end
