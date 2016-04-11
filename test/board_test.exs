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

  test "can mark every spot :X", %{board: board_pid} do
    mark_every_spot(board_pid, :X)
  end

  test "can mark every spot :O", %{board: board_pid} do
    mark_every_spot(board_pid, :O)
  end

  test "cannot mark a spot witn an :O when it is already marked with an :X", %{board: board_pid} do
    TTT.Board.mark_spot(board_pid, :top, :left, :X)
    TTT.Board.mark_spot(board_pid, :top, :left, :O)

    assert :X == TTT.Board.get_location(TTT.Board.get_board(board_pid), :top, :left)
  end

  defp mark_every_spot(board_pid, marker) do
    for row <- [:top, :middle, :bottom] do
      for column <- [:left, :middle, :right] do
        assert :blank == TTT.Board.get_location(TTT.Board.get_board(board_pid), row, column)

        TTT.Board.mark_spot(board_pid, row, column, marker)

        assert marker == TTT.Board.get_location(TTT.Board.get_board(board_pid), row, column)
      end
    end
  end
end
