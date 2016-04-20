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

  test "creating a match starts a game", %{game_registry: game_registry, player1: {name1, pid1} = player1, player2: {name2, _} = player2} do
    {:ok, _match_pid} = TTT.Match.start_link(game_registry, player1, player2)

    assert {_game_pid, ^name1, ^name2} = TTT.Game.Registry.get_game(game_registry, pid1)
  end

  test "When a game is won a second game starts", %{game_registry: game_registry, player1: {name1, pid1} = player1, player2: {name2, _} = player2} do
    moves = [{:top, :left}, {:middle, :left}, {:top, :middle}, {:middle, :middle}, {:top, :right}]
    {:ok, _match_pid} = TTT.Match.start_link(game_registry, player1, player2)
    {game_pid1, ^name1, ^name2} = TTT.Game.Registry.get_game(game_registry, pid1)

    TTTTest.Utils.play_games(moves, %{game: game_pid1, player1: player1, player2: player2}, fn _ -> nil end)

    {game_pid2, ^name2, ^name1} = TTT.Game.Registry.get_game(game_registry, pid1)
    assert game_pid1 != game_pid2
  end

  test "When a game is won by :O a second game starts", %{game_registry: game_registry, player1: {name1, pid1} = player1, player2: {name2, _} = player2} do
    moves = [{:bottom, :left}, {:top, :left}, {:middle, :left}, {:top, :middle}, {:middle, :middle}, {:top, :right}]
    {:ok, _match_pid} = TTT.Match.start_link(game_registry, player1, player2)
    {game_pid1, ^name1, ^name2} = TTT.Game.Registry.get_game(game_registry, pid1)

    TTTTest.Utils.play_games(moves, %{game: game_pid1, player1: player1, player2: player2}, fn _ -> nil end)

    {game_pid2, ^name1, ^name2} = TTT.Game.Registry.get_game(game_registry, pid1)
    assert game_pid1 != game_pid2
  end

  test "before a game is won the game is in a state of playing", %{game_registry: game_registry, player1: player1, player2: player2} do
    {:ok, match_pid} = TTT.Match.start_link(game_registry, player1, player2)
    assert :playing == TTT.Match.get_match_state(match_pid)
  end

  test "when a match is over, with 2 wins by player1 the game state is {:winner, player1}", %{game_registry: game_registry, player1: {name1, pid1} = player1, player2: {name2, _} = player2} do
    {:ok, match_pid} = TTT.Match.start_link(game_registry, player1, player2)

    {_game_pid1, ^name1, ^name2} = TTT.Game.Registry.get_game(game_registry, pid1)
    :ok = TTT.Match.mark_win(match_pid, pid1)

    {_game_pid2, ^name2, ^name1} = TTT.Game.Registry.get_game(game_registry, pid1)
    :ok = TTT.Match.mark_win(match_pid, pid1)

    assert {:winner, pid1} == TTT.Match.get_match_state(match_pid)
  end

  test "when a match is over, with 2 wins by player2 the game state is {:winner, player2}", %{game_registry: game_registry, player1: {name1, pid1} = player1, player2: {name2, pid2} = player2} do
    {:ok, match_pid} = TTT.Match.start_link(game_registry, player1, player2)

    {_game_pid1, ^name1, ^name2} = TTT.Game.Registry.get_game(game_registry, pid1)
    :ok = TTT.Match.mark_win(match_pid, pid2)

    {_game_pid2, ^name1, ^name2} = TTT.Game.Registry.get_game(game_registry, pid1)
    :ok = TTT.Match.mark_win(match_pid, pid2)

    assert {:winner, pid2} == TTT.Match.get_match_state(match_pid)
  end

  test "when a match is over, with 2 wins by player1 a new game is not started", %{game_registry: game_registry, player1: {name1, pid1} = player1, player2: {name2, pid2} = player2} do
    {:ok, match_pid} = TTT.Match.start_link(game_registry, player1, player2)

    {_game_pid1, ^name1, ^name2} = TTT.Game.Registry.get_game(game_registry, pid1)
    :ok = TTT.Match.mark_win(match_pid, pid1)

    {_game_pid2, ^name2, ^name1} = TTT.Game.Registry.get_game(game_registry, pid1)
    :ok = TTT.Match.mark_win(match_pid, pid1)

    assert :no_game == TTT.Player.get_game_state(pid1)
    assert :no_game == TTT.Player.get_game_state(pid2)
  end

  test "when a match is over, with 2 wins by player2 a new game is not started", %{game_registry: game_registry, player1: {name1, pid1} = player1, player2: {name2, pid2} = player2} do
    {:ok, match_pid} = TTT.Match.start_link(game_registry, player1, player2)

    {_game_pid1, ^name1, ^name2} = TTT.Game.Registry.get_game(game_registry, pid1)
    :ok = TTT.Match.mark_win(match_pid, pid2)

    {_game_pid2, ^name1, ^name2} = TTT.Game.Registry.get_game(game_registry, pid1)
    :ok = TTT.Match.mark_win(match_pid, pid2)

    assert :no_game == TTT.Player.get_game_state(pid1)
    assert :no_game == TTT.Player.get_game_state(pid2)
  end
end
