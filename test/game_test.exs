defmodule TTTTest.Game do
  use ExUnit.Case, async: true

  setup do
    {:ok, player_registry} = TTT.Player.Registry.start_link()
    player1 = create_player(player_registry, "player1", "player1_password")
    player2 = create_player(player_registry, "player2", "KNULHkek2@*&^knehk234")

    {:ok, game_pid} = TTT.Game.start_link(player1, player2)
    {:ok, %{game: game_pid, player1: player1, player2: player2}}
  end

  defp create_player(player_registry, name, password) do
    TTT.Player.Registry.create_player(player_registry, {name, password})
    TTT.Player.Registry.get_player(player_registry, {name, password})
  end

  test "a game can be started with a link" do
    {:ok, player1} = TTT.Player.start_link()
    {:ok, player2} = TTT.Player.start_link()

    assert {:ok, _pid} = TTT.Game.start_link({"player1", player1}, {"player2", player2})
  end

  test "a game's starting state", %{game: game_pid, player1: {name1, _pid1}} do
    empty_board = TTT.Board.empty_table()
    expected =
      {empty_board, name1, :playing}

    assert expected == TTT.Game.get_state(game_pid)
  end
end
