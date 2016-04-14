defmodule TTT.Player do
  def start_link(game_registry) do
    Agent.start_link(fn -> game_registry end)
  end
end
