defmodule TTT.Game do
  def start_link(_player1, _player2) do
    Agent.start_link(fn -> %{} end)
  end
end
