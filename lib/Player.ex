defmodule TTT.Player do
  def start_link(game_registry, name) do
    Agent.start_link(fn -> {game_registry, name} end)
  end

  def get_game_state(player_pid) do
    {game_registry, name} = get_state(player_pid)

    case TTT.Game.Registry.get_game(game_registry, {name, player_pid}) do
      :error -> :no_game
    end
  end

  defp get_state(player_pid) do
    Agent.get(player_pid, fn state -> state end)
  end
end
