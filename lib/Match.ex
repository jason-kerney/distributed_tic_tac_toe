defmodule TTT.Match do
  def start_link(game_registry, player1, player2) do
    {:ok, pid} = Agent.start_link(fn ->
      nil
    end)

    start_game(game_registry, player1, player2, pid)

    Agent.update(pid, fn _state -> {game_registry, player1, player2} end)

    {:ok, pid}
  end

  def mark_win(match_pid, player_pid) do

    {game_registry, {_, pid1} = p1, {_, pid2} = p2} = get_state(match_pid)

    {game_registry, {_, p1} = player1, {_, p2} = player2} = state =
      cond do
        player_pid == pid1 -> {game_registry, p2, p1}
        player_pid == pid2 -> {game_registry, p1, p2}
        true -> {:error, nil, nil}
      end

    if game_registry == :error do
      :error
    else
      TTT.Game.Registry.stop_game(game_registry, p1)
      Agent.update(match_pid, fn _ -> state end)
      TTT.Game.Registry.create_game(game_registry, player1, player2)
      :ok
    end
  end

  defp get_state(match_pid) do
    Agent.get(match_pid, fn state -> state end)
  end

  defp start_game(game_registry, player1, player2, pid) do
    TTT.Game.Registry.create_game(game_registry, player1, player2, pid)
  end
end
