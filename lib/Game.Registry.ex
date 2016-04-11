defmodule TTT.Game.Registry do
  use GenServer

  #Client API level
  def start_link do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def create_game(registry_pid, player_pid) do
    GenServer.cast(registry_pid, {:create, player_pid})
  end

  def get_game(registry_pid, player_pid) do
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
    {:ok, {{name, player_pid}, player2}} = Map.fetch(games, game_pid)
    {:reply, {game_pid, name, player2}, state}
  end

  def handle_cast({:create, {name, player_pid} = player}, {players, games, refs} = state) do
    if Map.has_key?(players, player_pid)  do
      {:noreply, state}
    else
      {:ok, game_pid} = TTT.Game.start_link()
      players = Map.put(players, player_pid, game_pid)
      games = Map.put(games, game_pid, {player, :noplayer})

      {:noreply, {players, games, refs}}
    end
  end
end
