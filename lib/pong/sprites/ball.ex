
defmodule Pong.Ball do
  
  alias __MODULE__

  @enforce_keys [:id]
  defstruct(
    id: :string,
    x_pos: 0,
    y_pos: 0
  )
  
end
