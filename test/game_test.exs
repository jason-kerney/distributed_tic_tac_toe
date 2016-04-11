defmodule TTTTest.Game do
  use ExUnit.Case, async: true

  test "a game can be started with a link" do
    {:ok, player1} = TTT.Player.start_link()
    {:ok, player2} = TTT.Player.start_link()

    assert {:ok, _pid} = TTT.Game.start_link({"player1", player1}, {"player2", player2})
  end
end
