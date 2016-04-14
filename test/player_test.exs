defmodule TTTTest.Player do
  use ExUnit.Case, async: true

  test "can start a link with a player" do
    assert {:ok, _pid} = TTT.Player.start_link(nil)
  end
end
