defmodule TTT.Match do
  def start_link(game_registry, player1, player2) do
    {:ok, pid} = Agent.start_link(fn ->
      nil
    end)

    start_game(game_registry, player1, player2, pid)

    Agent.update(pid, fn _state -> {game_registry, {player1, 0}, {player2, 0}, 0} end)

    {:ok, pid}
  end

  def mark_win(match_pid, player_pid) do
    {game_registry, {{p1_name, pid1}, p1_wins} = pl1, {{p2_name, pid2}, p2_wins} = pl2, r} = get_state(match_pid)

    {game_registry, {{_, p1} = player1, p1_wins}, {player2, p2_wins}, _rounds} = state =
      cond do
        player_pid == pid1 -> {game_registry, pl2, {{p1_name, pid1}, p1_wins + 1}, r+1}
        player_pid == pid2 -> {game_registry, pl1, {{p2_name, pid2}, p2_wins + 1}, r+1}
        true -> {:error, nil, nil}
      end

    if game_registry == :error do
      :error
    else
      TTT.Game.Registry.stop_game(game_registry, p1)
      Agent.update(match_pid, fn _ -> state end)

      if p1_wins < 2 and p2_wins < 2 do
        TTT.Game.Registry.create_game(game_registry, player1, player2)
      end

      :ok
    end
  end

  def mark_tie(match_pid, player_pid1, player_pid2) do
    {game_registry, {{_p1_name, pid1}, _p1_wins} = pl1, {{_p2_name, pid2}, _p2_wins} = pl2, r} = get_state(match_pid)
    {game_registry, {{_, p1} = player1, p1_wins}, {player2, p2_wins}, _rounds} = state =
      cond do
        (player_pid1 == pid1 or player_pid2 == pid1) and (player_pid2 == pid1 or player_pid2 == pid2) ->
          {game_registry, pl2, pl1, r+1}
        true -> {:error, nil, nil}
      end

    if game_registry == :error do
      :error
    else
      TTT.Game.Registry.stop_game(game_registry, p1)
      Agent.update(match_pid, fn _ -> state end)

      if p1_wins < 2 and p2_wins < 2 do
        TTT.Game.Registry.create_game(game_registry, player1, player2)
      end

      :ok
    end
  end

  def get_match_state(match_pid) do
    state = get_state(match_pid)
    case state do
      {_, {_, p1_wins}, {_, p2_wins}, _} when p1_wins < 2 and p2_wins < 2 -> :playing
      {_, {{_, p1_pid}, p1_wins}, _} when p1_wins >= 2 -> {:winner, p1_pid}
      {_, _, {{_, p2_pid}, p2_wins}, _} when p2_wins >= 2 -> {:winner, p2_pid}
      _ -> :error
    end
  end

  def get_match_score(match_pid) do
    {_, {{p1, _}, score1}, {{p2, _}, score2}, _} = get_state(match_pid)
    {{p1, score1}, {p2, score2}}
  end

  defp get_state(match_pid) do
    Agent.get(match_pid, fn state -> state end)
  end

  defp start_game(game_registry, player1, player2, pid) do
    TTT.Game.Registry.create_game(game_registry, player1, player2, pid)
  end
end
