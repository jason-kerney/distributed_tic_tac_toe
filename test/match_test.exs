defmodule TTTTest.Match do
  use ExUnit.Case, async: true

  setup do
    {:ok, game_registry} = TTT.Game.Registry.start_link()
    {:ok, player_regirsty} = TTT.Player.Registry.start_link(game_registry)

    player1_key = {"me", "pl@y3R1"}
    player2_key = {"you", "Pl@y3r2"}

    TTT.Player.Registry.create_player(player_regirsty, player1_key)
    TTT.Player.Registry.create_player(player_regirsty, player2_key)

    player1 = TTT.Player.Registry.get_player(player_regirsty, player1_key)
    player2 = TTT.Player.Registry.get_player(player_regirsty, player2_key)

    {:ok, %{game_registry: game_registry, player1: player1, player2: player2}}
  end

  test "can start a link to a match", %{game_registry: game_registry, player1: player1, player2: player2} do
    assert {:ok, _pid} = TTT.Match.start_link(game_registry, player1, player2)
  end
end
