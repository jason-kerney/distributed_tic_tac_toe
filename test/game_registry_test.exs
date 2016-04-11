defmodule TTTTest.Game.Registry do
  use ExUnit.Case, async: true

  test "can create a game registry" do
    assert {:ok, _pid} = TTT.Game.Registry.start_link()
  end

  setup do
    {:ok, game_registry} = TTT.Game.Registry.start_link()
    {:ok, player_registry} = TTT.Player.Registry.start_link()
    TTT.Player.Registry.create_player(player_registry, {"Player1", "Player1_Password"})
    TTT.Player.Registry.create_player(player_registry, {"Player2", "Player2_Password"})

    player1 = TTT.Player.Registry.get_player(player_registry, {"Player1", "Player1_Password"})
    player2 = TTT.Player.Registry.get_player(player_registry, {"Player2", "Player2_Password"})
    {:ok, %{game_registry: game_registry, player1: player1, player2: player2}}
  end

  test "a game registry can create a game for a player", %{game_registry: game_registry, player1: {name, _player_pid} = player} do
    TTT.Game.Registry.create_game(game_registry, player)

    assert {_game_pid, ^name, :noplayer} = TTT.Game.Registry.get_game(game_registry, player)
  end

  test "can add a player to an existing game", %{game_registry: game_registry, player1: {player1_name, _pid} = player1, player2: {player2_name, _player_pid} = player2} do
    TTT.Game.Registry.create_game(game_registry, player1)
    {game_pid, _name, :noplayer} = TTT.Game.Registry.get_game(game_registry, player1)

    TTT.Game.Registry.add_player(game_registry, game_pid, player2)

    assert {^game_pid, ^player1_name, ^player2_name} = TTT.Game.Registry.get_game(game_registry, player1)
    assert {^game_pid, ^player1_name, ^player2_name} = TTT.Game.Registry.get_game(game_registry, player2)
  end
end
