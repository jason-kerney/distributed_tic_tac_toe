defmodule TTT.Player.Registry do
  use GenServer

  # api side
  def start_link(game_registry) do
    GenServer.start_link(__MODULE__, {:game_registry, game_registry}, [])
  end

  def create_player(pid, player_info) do
    GenServer.cast(pid, {:create, player_info})
  end

  def get_player(pid, person) do
    GenServer.call(pid,{:lookup, person})
  end

  def stop(pid) do
    GenServer.stop(pid)
  end

  # server side
  def init(:ok) do
    game_registry = TTT.Game.Registry.start_link()
    init_state(game_registry)
  end

  def init({:game_registry, pid}) do
    init_state(pid)
  end

  defp init_state(game_registry) do
    players = %{}
    refs = %{}
    {:ok, {game_registry, players, refs}}
  end

  def handle_cast({:create, {name, _} = player_info}, {game_registry, players, refs}) do
    if Map.has_key?(players, player_info)  do
      {:noreply, {game_registry, players, refs}}
    else
      {:ok, player} = TTT.Player.start_link(game_registry, name)
      ref = Process.monitor(player)
      refs = Map.put(refs, ref, player_info)
      players = Map.put(players, player_info, player)

      {:noreply, {game_registry, players, refs}}
    end
  end

  def handle_call({:lookup, {name, _password} = player_info}, _from, {_, players, _} = state) do
    result = Map.fetch(players, player_info)

    case result do
      {:ok, pid} -> {:reply, {name, pid}, state}
      _ -> {:reply, result, state}
    end

  end

  def handle_info({:DOWN, ref, :process, _pid, _reson}, {game_registry, players, refs}) do
    {player_info, refs} = Map.pop(refs, ref)
    {player_pid, players} = Map.pop(players, player_info)

    end_game(game_registry, player_pid)

    {:noreply, {game_registry, players, refs}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp end_game(game_registry, player_pid) do
    result = TTT.Game.Registry.get_game(game_registry, player_pid)
    case result do
      {game_pid, _, _} -> Agent.stop(game_pid)
      _ -> :ok
    end
  end
end
