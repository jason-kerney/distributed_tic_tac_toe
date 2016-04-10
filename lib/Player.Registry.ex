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
    {:ok, %{}}
  end

  def handle_cast({:create, player_info}, players) do
    if Map.has_key?(players, player_info)  do
      {:noreply, players}
    else
      {:ok, player} = TTT.Player.start_link()
      {:noreply, Map.put(players, player_info, player), players}
    end
  end

  def handle_call({:lookup, {name, _password} = player_info}, _from, players) do
    {:reply, {name, Map.fetch(players, player_info)}, players}
  end
end
