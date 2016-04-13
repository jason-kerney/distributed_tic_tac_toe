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

    marker = get_marker(player_pid, pid1, pid2, npid)

    if marker == :error do
      :error
    else
      update_game(game_pid, board_pid, player_pid, row, column, marker)
    end
  end

  defp get_marker(player, p1, p2, current) do
      case {player, player} do
        {^p1, ^current} -> :X
        {^p2, ^current} -> :O
        _ -> :error
      end
  end

  defp update_game(game_pid, board_pid, current, row, column, marker) do
    TTT.Board.mark_spot(board_pid, row, column, marker)
    set_next_player(game_pid, current)
  end

  defp set_next_player(game_pid, current) do
    Agent.update(game_pid,
      fn
        {board_pid, {_, id1} = p1, {_, id2} = p2, _, _} ->
          play_state = get_play_state(board_pid)
          next =
            case {current, play_state} do
              {^id1, :winner} -> p1
              {^id2, :winner} -> p2
              {^id1, _} -> p2
              {^id2, _} -> p1
            end

          {board_pid, p1, p2, play_state, next}
      end)
  end

  defp get_play_state(board_pid) do
    {tr, mr, br} = board = TTT.Board.get_board(board_pid)
    {cl, cm, cr} = TTT.Board.to_colums(board)
    cond do
      is_winner?(tr) -> :winner
      is_winner?(mr) -> :winner
      is_winner?(br) -> :winner
      is_winner?(cl) -> :winner
      is_winner?(cm) -> :winner
      is_winner?(cr) -> :winner
      true -> :playing
    end
  end

  defp is_winner?({a, b, c}) do
    a == b and b == c and a != :blank
  end
end
