defmodule TTT.Game do
  def start_link() do
    Agent.start_link(fn -> %{} end)
  end
end
