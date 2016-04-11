defmodule TTT.Game.Registry do
  use GenServer

  #Client API level
  def start_link do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def create_game(registry_pid, player1, player2) do
    GenServer.cast(registry_pid, {:create, {player1, player2}})
  end

  def get_game(registry_pid, {_name, player_pid}) do
    GenServer.call(registry_pid, {:lookup, player_pid})
  end

  #Server Level
  def init(:ok) do
    players = %{}
    games = %{}
    refs = %{}

    {:ok, {players, games, refs}}
  end

  def handle_call({:lookup, player_pid}, _from, {players, games, _refs} = state) do
    {:ok, game_pid} = Map.fetch(players, player_pid)
    {:ok, {{name1, _pid1}, {name2, _pid2}}} = Map.fetch(games, game_pid)

    {:reply, {game_pid, name1, name2}, state}
  end

  def handle_cast({:create, {{_name1, player_pid1} = player1, {_name2, player_pid2} = player2}}, {players, games, refs} = state) do
    if Map.has_key?(players, player_pid1) or Map.has_key?(players, player_pid2)  do
      {:noreply, state}
    else
      {:ok, game_pid} = TTT.Game.start_link()
      players = Map.put(players, player_pid1, game_pid)
      players = Map.put(players, player_pid2, game_pid)
      games = Map.put(games, game_pid, {player1, player2})

      {:noreply, {players, games, refs}}
    end
  end
end
