defmodule TTTTest.Board do
  use ExUnit.Case, async: true

  test "can create a link to a board" do
    assert {:ok, pid} = TTT.Board.start_link()
  end
end
