defmodule TTT.Match do
  def start_link(game_registry, player1, player2) do
    Agent.start_link(fn ->
      start_game(game_registry, player1, player2)
      {game_registry, player1, player2}
    end)
  end

  defp start_game(game_registry, player1, player2) do
    TTT.Game.Registry.create_game(game_registry, player1, player2)
  end
end
