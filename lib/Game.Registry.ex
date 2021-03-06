defmodule TTT.Game.Registry do
  use GenServer

  #Client API level
  def start_link do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def create_game(registry_pid, player1, player2, match_pid \\ nil) do
    GenServer.cast(registry_pid, {:create, {player1, player2, match_pid}})
  end

  def get_game(registry_pid, {_, player_pid}) do
    GenServer.call(registry_pid, {:lookup, player_pid})
  end

  def get_game(registry_pid, player_pid) do
    GenServer.call(registry_pid, {:lookup, player_pid})
  end

  def stop_game(registry_pid, player_pid) do
    GenServer.call(registry_pid, {:stop_game, player_pid})
  end

  def stop(registry_pid) do
    GenServer.stop(registry_pid)
  end

  #Server Level
  def init(:ok) do
    players = %{}
    games = %{}
    refs = %{}

    {:ok, {players, games, refs}}
  end

  def handle_call({:lookup, player_pid}, _from, {players, games, _refs} = state) do
    result = Map.fetch(players, player_pid)

    case result do
      {:ok, game_pid} ->
        {:ok, {{name1, _pid1}, {name2, _pid2}}} = Map.fetch(games, game_pid)

        {:reply, {game_pid, name1, name2}, state}
      _ -> {:reply, result, state}
    end
  end

  def handle_call({:stop_game, player_pid}, _from, {players, _games, _refs} = state) do
    if Map.has_key?(players, player_pid)  do
      game_pid = Map.get(players, player_pid)
      Agent.stop(game_pid)
      {:reply, :ok, state}
    else
      {:reply, :ok, state}
    end
  end

  def handle_cast({:create, {{_name1, player_pid1} = player1, {_name2, player_pid2} = player2, match_pid}}, {players, games, refs} = state) do
    if Map.has_key?(players, player_pid1) or Map.has_key?(players, player_pid2)  do
      {:noreply, state}
    else
      {:ok, game_pid} = TTT.Game.start_link(player1, player2, match_pid)
      ref = Process.monitor(game_pid)

      refs = Map.put(refs, ref, game_pid)
      players = Map.put(players, player_pid1, game_pid)
      players = Map.put(players, player_pid2, game_pid)
      games = Map.put(games, game_pid, {player1, player2})

      {:noreply, {players, games, refs}}
    end
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {players, games, refs}) do
    {game_pid, refs} = Map.pop(refs, ref)
    {{{_, player1_pid}, {_, player2_pid}}, games} = Map.pop(games, game_pid)
    players = Map.delete(players, player1_pid)
    players = Map.delete(players, player2_pid)

    {:noreply, {players, games, refs}}
  end
end
