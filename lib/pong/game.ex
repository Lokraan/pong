
# Server side detection
# Camera concept

defmodule Pong.Game do
  use GenServer

  alias Pong.GameState

  def start_link(opts) do
    game_id = Keyword.fetch!(opts, :game_id)

    GenServer.start_link(__MODULE__, [game_id],
      name: {:via, Registry, {Pong.Registry, get_pid(game_id)}}
    )
  end

  def init([game_id]) do
    IO.puts "Init game_id: #{game_id}"
    state = %{
      game_id: game_id,
      players: %{},
      max_players: 6
    }

    {:ok, state}
  end

  def find!(game_id) do
    case Registry.lookup(Pad.Registry, get_pid(game_id)) do
      [{pid, _}] ->
        pid
      [] ->
        raise ArgumentError, 
          "No process found for pad id #{inspect(pad_id)}"
    end
  end

  defp get_pid(game_id), do: "game:#{game_id}"

  def get_state(game_id) do
    game_id
    |> find!()
    |> GenServer.call(:get_state)
  end

  def handle_call(:get_state) do
    {:reply, state, state}
  end

end
