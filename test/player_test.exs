defmodule TTTTest.Player do
  use ExUnit.Case, async: true

  setup do
    {:ok, game_registry} = TTT.Game.Registry.start_link()

    p1_info = {"Player1", "1@3$5^7*9)-AbC"}
    p2_info = {"Player2", "cBaD-!2#4%6&8(0"}
    p3_info = {"Player3", "god_M0d3"}

    {:ok, player_registry} = TTT.Player.Registry.start_link(game_registry)
    TTT.Player.Registry.create_player(player_registry, p1_info)
    TTT.Player.Registry.create_player(player_registry, p2_info)
    TTT.Player.Registry.create_player(player_registry, p3_info)

    player1 = TTT.Player.Registry.get_player(player_registry, p1_info)
    player2 = TTT.Player.Registry.get_player(player_registry, p2_info)
    player3 = TTT.Player.Registry.get_player(player_registry, p3_info)

    TTT.Game.Registry.create_game(game_registry, player1, player2)

    {:ok, %{game_registry: game_registry, player_registry: player_registry, player1: player1, player2: player2, no_game: player3}}
  end

  test "can start a link with a player" do
    assert {:ok, _pid} = TTT.Player.start_link(nil, "player")
  end

  test "a player can is told when they do not belong to a game.", %{no_game: {_, player_pid}} do
    assert :no_game == TTT.Player.get_game_state(player_pid)
  end

  test "a player can get the state of a game they belong to", %{player1: {name1, pid1}, player2: {_, pid2}} do
    empty_board = TTT.Board.empty_table()
    expected =
      {empty_board, name1, :playing}

    assert expected == TTT.Player.get_game_state(pid1)
    assert expected == TTT.Player.get_game_state(pid2)
  end
end
