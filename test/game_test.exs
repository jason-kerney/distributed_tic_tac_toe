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

  test "player 1 can mark the board with an :X changing player2 to be the active player", %{game: game_pid, player1: {_, pid1}, player2: {name2, _}} do
    empty_row = TTT.Board.empty_row()
    expected =
      {{{:X, :blank, :blank}, empty_row, empty_row}, name2, :playing}

    TTT.Game.mark_spot(game_pid, pid1, :top, :left)

    assert expected == TTT.Game.get_state(game_pid)
  end

  test "player2 cannot play before player1", %{game: game_pid, player1: {name1, _}, player2: {_, pid2}} do
    empty_board = TTT.Board.empty_table()
    expected = {empty_board, name1, :playing}

    TTT.Game.mark_spot(game_pid, pid2, :top, :left)

    assert expected == TTT.Game.get_state(game_pid)
  end

  test "player2 marks a spot with an :O", %{game: game_pid, player1: {name1, pid1}, player2: {_, pid2}} do
    empty_row = TTT.Board.empty_row()
    expected = {{{:X, :O, :blank}, empty_row, empty_row}, name1, :playing}

    TTT.Game.mark_spot(game_pid, pid1, :top, :left)
    TTT.Game.mark_spot(game_pid, pid2, :top, :middle)

    assert expected == TTT.Game.get_state(game_pid)
  end

  test "player1 cannot mark 2 spots in a row", %{game: game_pid, player1: {_, pid1}, player2: {name2, _}} do
    empty_row = TTT.Board.empty_row()
    expected = {{{:X, :blank, :blank}, empty_row, empty_row}, name2, :playing}

    TTT.Game.mark_spot(game_pid, pid1, :top, :left)
    TTT.Game.mark_spot(game_pid, pid1, :top, :middle)

    assert expected == TTT.Game.get_state(game_pid)
  end

  test "a win is :X's all in the top row", %{player1: {name1, _}} = state do
    empty_row = TTT.Board.empty_row()
    expected = {{{:X, :X, :X}, {:O, :O, :blank}, empty_row}, name1, :winner}
    moves = [{:top, :left}, {:middle, :left}, {:top, :middle}, {:middle, :middle}, {:top, :right}]

    result = play_game(moves, state)

    assert expected == result
  end

  test "a win is :O's all in the top row", %{player2: {name2, _}} = state do
    expected = {{{:O, :O, :O}, {:X, :X, :blank}, {:blank, :blank, :X}}, name2, :winner}
    moves = [{:bottom, :right}, {:top, :left}, {:middle, :left}, {:top, :middle}, {:middle, :middle}, {:top, :right}]

    result = play_game(moves, state)

    assert expected == result
  end

  test "a win is :X's all in the middle row", %{player1: {name1, _}} = state do
    empty_row = TTT.Board.empty_row()
    expected = {{empty_row, {:X, :X, :X}, {:O, :O, :blank}}, name1, :winner}
    moves = [{:middle, :left}, {:bottom, :left}, {:middle, :middle}, {:bottom, :middle}, {:middle, :right}]

    result = play_game(moves, state)

    assert expected == result
  end

  test "a win is :O's all in the middle row", %{player2: {name2, _}} = state do
    expected = {{{:X, :blank, :blank}, {:O, :O, :O}, {:X, :X, :blank}}, name2, :winner}
    moves = [{:top, :left}, {:middle, :left}, {:bottom, :left}, {:middle, :middle}, {:bottom, :middle}, {:middle, :right}]

    result = play_game(moves, state)

    assert expected == result
  end

  test "a win is :X's all in the bottom row", %{player1: {name1, _}} = state do
    empty_row = TTT.Board.empty_row()
    expected = {{empty_row, {:O, :O, :blank}, {:X, :X, :X}}, name1, :winner}
    moves = [{:bottom, :left}, {:middle, :left}, {:bottom, :middle}, {:middle, :middle}, {:bottom, :right}]

    result = play_game(moves, state)

    assert expected == result
  end

  test "a win is :O's all in the bottom row", %{player2: {name2, _}} = state do
    expected = {{{:X, :blank, :blank}, {:X, :X, :blank}, {:O, :O, :O}}, name2, :winner}
    moves = [{:top, :left}, {:bottom, :left}, {:middle, :left}, {:bottom, :middle}, {:middle, :middle}, {:bottom, :right}]

    result = play_game(moves, state)

    assert expected == result
  end

  test "a win is :X's all in the left column", %{player1: {name1, _}} = state do
    expected = {{{:X, :O, :blank}, {:X, :O, :blank}, {:X, :blank, :blank}}, name1, :winner}
    moves = [{:top, :left}, {:top, :middle}, {:middle, :left}, {:middle, :middle}, {:bottom, :left}]

    result = play_game(moves, state)

    assert expected == result
  end

  test "a win is :O's all in the left column", %{player2: {name2, _}} = state do
    expected = {{{:O, :X, :X}, {:O, :X, :blank}, {:O, :blank, :blank}}, name2, :winner}
    moves = [{:top, :right}, {:top, :left}, {:top, :middle}, {:middle, :left}, {:middle, :middle}, {:bottom, :left}]

    result = play_game(moves, state)

    assert expected == result
  end

  test "a win is :X's all in the middle column", %{player1: {name1, _}} = state do
    expected = {{{:O, :X, :blank}, {:O, :X, :blank}, {:blank, :X, :blank}}, name1, :winner}
    moves = [{:top, :middle}, {:top, :left}, {:middle, :middle}, {:middle, :left}, {:bottom, :middle}]

    result = play_game(moves, state)

    assert expected == result
  end

  test "a win is :O's all in the middle column", %{player2: {name2, _}} = state do
    expected = {{{:X, :O, :X}, {:X, :O, :blank}, {:blank, :O, :blank}}, name2, :winner}
    moves = [{:top, :right}, {:top, :middle}, {:top, :left}, {:middle, :middle}, {:middle, :left}, {:bottom, :middle}]

    result = play_game(moves, state)

    assert expected == result
  end

  test "a win is :X's all in the right column", %{player1: {name1, _}} = state do
    expected = {{{:O, :blank, :X}, {:O, :blank, :X}, {:blank, :blank, :X}}, name1, :winner}
    moves = [{:top, :right}, {:top, :left}, {:middle, :right}, {:middle, :left}, {:bottom, :right}]

    result = play_game(moves, state)

    assert expected == result
  end

  test "a win is :O's all in the right column", %{player2: {name2, _}} = state do
    expected = {{{:X, :X, :O}, {:X, :blank, :O}, {:blank, :blank, :O}}, name2, :winner}
    moves = [{:top, :middle}, {:top, :right}, {:top, :left}, {:middle, :right}, {:middle, :left}, {:bottom, :right}]

    result = play_game(moves, state)

    assert expected == result
  end

  test "a win is all :X's diagnal top left to bottom right", %{player1: {name1, _}} = state do
    expected = {{{:X, :O, :blank}, {:O, :X, :blank}, {:blank, :blank, :X}}, name1, :winner}
    moves = [{:top, :left}, {:top, :middle}, {:middle, :middle}, {:middle, :left}, {:bottom, :right}]

    result = play_game(moves, state)

    assert expected == result
  end

  test "a win is all :O's diagnal top left to bottom right", %{player2: {name2, _}} = state do
    expected = {{{:O, :X, :X}, {:X, :O, :blank}, {:blank, :blank, :O}}, name2, :winner}
    moves = [{:top, :right}, {:top, :left}, {:top, :middle}, {:middle, :middle}, {:middle, :left}, {:bottom, :right}]

    result = play_game(moves, state)

    assert expected == result
  end

  defp play_game(moves, %{game: game_pid, player1: p1} = state) do
    play_game(moves, state, p1)
    TTT.Game.get_state(game_pid)
  end

  defp play_game([{row, column}|rest], %{game: game_pid, player1: p1, player2: p2} = state, {_, cpid} = current) do
    next =
      case current do
        ^p1 -> p2
        ^p2 -> p1
      end

      TTT.Game.mark_spot(game_pid, cpid, row, column)
      play_game(rest, state, next)
  end

  defp play_game([], _, _) do
    :ok
  end
end
