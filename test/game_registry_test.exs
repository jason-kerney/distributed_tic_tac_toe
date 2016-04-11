defmodule TTTTest.Game.Registry do
  use ExUnit.Case, async: true

  setup do
    {:ok, game_registry} = TTT.Game.Registry.start_link()
    {:ok, player_registry} = TTT.Player.Registry.start_link()
    TTT.Player.Registry.create_player(player_registry, {"Player1", "Player1_Password"})
    TTT.Player.Registry.create_player(player_registry, {"Player2", "Player2_Password"})

    player1 = TTT.Player.Registry.get_player(player_registry, {"Player1", "Player1_Password"})
    player2 = TTT.Player.Registry.get_player(player_registry, {"Player2", "Player2_Password"})
    {:ok, %{game_registry: game_registry, player1: player1, player2: player2}}
  end

  test "can create a game registry" do
    assert {:ok, _pid} = TTT.Game.Registry.start_link()
  end

  test "a game registry can create a game for a player", %{game_registry: game_registry, player1: {name1, _pid1} = player1, player2: {name2, _pid2} = player2} do
    TTT.Game.Registry.create_game(game_registry, player1, player2)

    assert {_game_pid, ^name1, ^name2} = TTT.Game.Registry.get_game(game_registry, player1)
  end
end
