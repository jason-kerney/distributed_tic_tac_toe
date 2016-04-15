defmodule TTT.Player do
  def start_link(game_registry, name) do
    Agent.start_link(fn -> {game_registry, name} end)
  end

  def get_game_state(player_pid) do
    {game_registry, name} = get_state(player_pid)

    case TTT.Game.Registry.get_game(game_registry, {name, player_pid}) do
      :error -> :no_game
      {game, _, _} -> TTT.Game.get_state(game)
    end
  end

  def mark_spot(player_pid, row, column) do
    success_action =
      fn ({game, _, _}, {name, pid} = player) ->
        TTT.Game.mark_spot(game, pid, row, column)
      end

    fail_action = fn _ ->
      IO.puts "Failed"
      :ok
    end

    handle_game(player_pid, success_action, fail_action)
  end

  defp handle_game(player_pid, success_action, fail_action) do
    {game_registry, name} = get_state(player_pid)
    player = {name, player_pid}
    game = TTT.Game.Registry.get_game(game_registry, player)

    case game do
      :error -> fail_action.(game, player)
      {_, _, _} -> success_action.(game, player)
    end
  end

  defp get_state(player_pid) do
    Agent.get(player_pid, fn state -> state end)
  end
end
