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

  test "I can get any location on a board" do
    board =
      {
        {"top left"   , "top middle"   , "top right"   },
        {"middle left", "middle middle", "middle right"},
        {"bottom left", "bottom middle", "bottom right"}
      }

    assert "top left"   == TTT.Board.get_location(board, :top, :left)
    assert "top middle" == TTT.Board.get_location(board, :top, :middle)
    assert "top right"  == TTT.Board.get_location(board, :top, :right)

    assert "middle left"   == TTT.Board.get_location(board, :middle, :left)
    assert "middle middle" == TTT.Board.get_location(board, :middle, :middle)
    assert "middle right"  == TTT.Board.get_location(board, :middle, :right)

    assert "bottom left"   == TTT.Board.get_location(board, :bottom, :left)
    assert "bottom middle" == TTT.Board.get_location(board, :bottom, :middle)
    assert "bottom right"  == TTT.Board.get_location(board, :bottom, :right)

  end
end
