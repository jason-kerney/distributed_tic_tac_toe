defmodule TTT.Game do
  def start_link(player1, player2, match_pid \\ nil) do
    {:ok, board} = TTT.Board.start_link()

    Agent.start_link(fn -> {board, player1, player2, :playing, player1, match_pid} end)
  end

  def get_state(game_pid) do
    {board_pid, _, _, play_state, {name, _}, _} = get(game_pid)

    board = TTT.Board.get_board(board_pid)

    case play_state do
      :draw -> {board, play_state}
       _ -> {board, name, play_state}
    end

  end

  defp get(game_pid) do
    Agent.get(game_pid, fn state -> state end)
  end

  def mark_spot(game_pid, player_pid, row, column) do
    {board_pid, {_, pid1}, {_, pid2}, _, {_, npid}, match_pid} = get(game_pid)
    marker = get_marker(player_pid, pid1, pid2, npid)

    if marker == :error do
      :error
    else
      update_game(game_pid, board_pid, player_pid, row, column, marker, match_pid)
    end
  end

  defp get_marker(player, p1, p2, current) do
      case {player, player} do
        {^p1, ^current} -> :X
        {^p2, ^current} -> :O
        _ -> :error
      end
  end

  defp update_game(game_pid, board_pid, current, row, column, marker, match_pid) do
    TTT.Board.mark_spot(board_pid, row, column, marker)
    set_next_player(game_pid, current, match_pid)
  end

  defp set_next_player(game_pid, current, match_pid) do
    result = Agent.update(game_pid,
      fn
        {board_pid, {_, id1} = p1, {_, id2} = p2, _, _, _} ->
          play_state = get_play_state(board_pid)
          {_, np} = next =
            case {current, play_state} do
              {^id1, :winner} -> p1
              {^id2, :winner} -> p2
              {^id1, _} -> p2
              {^id2, _} -> p1
            end

          {board_pid, p1, p2, play_state, next, match_pid}
      end)

    {_, _, _, play_state, {_, cpid}, mpid} = get(game_pid)

    if play_state == :winner and mpid != nil do
      TTT.Match.mark_win(mpid, cpid)
    end

    result
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
      true ->
        case board do
          {
            {tl,  _,  _},
            { _, mm,  _},
            { _,  _, br}
          } when tl == mm and mm == br and tl != :blank -> :winner
          {
            { _,  _, tr},
            { _, mm,  _},
            {bl,  _,  _}
          } when tr == mm and mm == bl and tr != :blank -> :winner
          {
            {a, b, c},
            {d, e, f},
            {g, h, i}
          } when a != :blank and b != :blank and c != :blank and d != :blank and
                 e != :blank and f != :blank and g != :blank and h != :blank and
                 i != :blank -> :draw
          _ -> :playing
        end
    end
  end

  defp is_winner?({a, b, c}) do
    a == b and b == c and a != :blank
  end
end
