defmodule TTT.Game do
  def start_link(player1, player2) do
    {:ok, board} = TTT.Board.start_link()

    Agent.start_link(fn -> {board, player1, player2, :playing, player1} end)
  end

  def get_state(game_pid) do
    {board_pid, _, _, play_state, {name, _}} = get(game_pid)

    board = TTT.Board.get_board(board_pid)
    {board, name, play_state}
  end

  defp get(game_pid) do
    Agent.get(game_pid, fn state -> state end)
  end

  def mark_spot(game_pid, player_pid, row, column) do
    {board_pid, {_, pid1}, {_, pid2}, _, {_, npid}} = get(game_pid)

    marker =
      case {player_pid, player_pid} do
        {^pid1, ^npid} -> :X
        {^pid2, ^npid} -> :O
        _ -> :error
      end

    if marker == :error do
      :error
    else
      TTT.Board.mark_spot(board_pid, row, column, marker)
      Agent.update(game_pid,
        fn
          {board_pid, {_, id1} = p1, {_, id2} = p2, play_state, _} ->
            next =
              case player_pid do
                ^id1 -> p2
                ^id2 -> p1
              end

            {board_pid, p1, p2, play_state, next}
        end)
    end
  end
end
