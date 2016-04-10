defmodule TTTTest.Game do
  use ExUnit.Case, async: true

  test "a game can be start a link" do
    assert {:ok, _pid} = TTT.Game.start_link()
  end
end
