defmodule TTT.Player.Registry do
  use GenServer

  # api side
  def start_link() do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def create_player(pid, player_info) do
    GenServer.cast(pid, {:create, player_info})
  end

  def get_player(pid, person) do
    GenServer.call(pid,{:lookup, person})
  end

  # server side
  def init(:ok) do
    players = %{}
    refs = %{}
    {:ok, {players, refs}}
  end

  def handle_cast({:create, player_info}, {players, refs}) do
    if Map.has_key?(players, player_info)  do
      {:noreply, {players, refs}}
    else
      {:ok, player} = TTT.Player.start_link()
      ref = Process.monitor(player)
      refs = Map.put(refs, ref, player_info)
      players = Map.put(players, player_info, player)

      {:noreply, {players, refs}}
    end
  end

  def handle_call({:lookup, {name, _password} = player_info}, _from, {players, _} = state) do
    result = Map.fetch(players, player_info)

    case result do
      {:ok, pid} -> {:reply, {name, pid}, state}
      _ -> {:reply, result, state}
    end

  end

  def handle_info({:DOWN, ref, :process, _pid, _reson}, {players, refs}) do
    {player_info, refs} = Map.pop(refs, ref)
    players = Map.delete(players, player_info)
    {:noreply, {players, refs}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
