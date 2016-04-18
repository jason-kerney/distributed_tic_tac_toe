defmodule TTTTest.Utils do
  def play_game(moves, %{game: game_pid, player1: p1} = state) do
    play_game(moves, state, p1)
    TTT.Game.get_state(game_pid)
  end

  def play_game([{row, column}|rest], %{game: game_pid, player1: p1, player2: p2} = state, {_, cpid} = current) do
    next =
      case current do
        ^p1 -> p2
        ^p2 -> p1
      end

      TTT.Game.mark_spot(game_pid, cpid, row, column)
      play_game(rest, state, next)
  end

  def play_game([], _, _) do
    :ok
  end
end
