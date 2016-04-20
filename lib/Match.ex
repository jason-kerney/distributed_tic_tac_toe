defmodule TTT.Match do
  def start_link(game_registry, player1, player2) do
    {:ok, pid} = Agent.start_link(fn ->
      nil
    end)

    start_game(game_registry, player1, player2, pid)

    Agent.update(pid, fn _state -> {game_registry, {player1, 0}, {player2, 0}} end)

    {:ok, pid}
  end

  def mark_win(match_pid, player_pid) do
    {game_registry, {{p1_name, pid1}, p1_wins} = pl1, {{p2_name, pid2}, p2_wins} = pl2} = get_state(match_pid)

    {game_registry, {{_, p1} = player1, p1_wins}, {player2, p2_wins}} = state =
      cond do
        player_pid == pid1 -> {game_registry, pl2, {{p1_name, pid1}, p1_wins + 1}}
        player_pid == pid2 -> {game_registry, pl1, {{p2_name, pid2}, p2_wins + 1}}
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
      {_, {_, p1_wins}, {_, p2_wins}} when p1_wins < 2 and p2_wins < 2 -> :playing
      {_, {{_, p1_pid}, p1_wins}, _} when p1_wins >= 2 -> {:winner, p1_pid}
      {_, _, {{_, p2_pid}, p2_wins}} when p2_wins >= 2 -> {:winner, p2_pid}
      _ -> :error
    end
  end

  defp get_state(match_pid) do
    Agent.get(match_pid, fn state -> state end)
  end

  defp start_game(game_registry, player1, player2, pid) do
    TTT.Game.Registry.create_game(game_registry, player1, player2, pid)
  end
end
