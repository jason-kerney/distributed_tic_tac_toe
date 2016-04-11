defmodule TTTTest.Board do
  use ExUnit.Case, async: true

  setup do
    {:ok, board_pid} = TTT.Board.start_link()
    {:ok, board: board_pid}
  end

  test "can create a link to a board" do
    assert {:ok, _pid} = TTT.Board.start_link()
  end

  test "a board starts empty", %{board: board_pid} do
    empty = TTT.Board.empty_table()

    assert empty == TTT.Board.get_board(board_pid)
  end
end
