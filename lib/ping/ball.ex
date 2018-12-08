defmodule Ping.Ball do
  @enforce_keys [:id]

  alias __MODULE__
  defstruct(
    id: :string,
    x_pos: 0,
    y_pos: 0
  )
end
