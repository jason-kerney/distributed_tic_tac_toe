defmodule TTT.Game do
  def start_link(player1, player2) do
    {:ok, board} = TTT.Board.start_link()

    Agent.start_link(fn -> {board, player1, player2, :playing} end)
  end

  def get_state(game_pid) do
    Agent.get(game_pid,
      fn {board_pid, {name1, _}, _, state} ->
        board = TTT.Board.get_board(board_pid)
        {board, name1, state} 
      end
    )
  end
end
