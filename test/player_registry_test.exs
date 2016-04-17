defmodule TTTTest.Player.Registry do
  use ExUnit.Case, async: true

  test "can create a registry" do
    assert {:ok, _pid} = TTT.Player.Registry.start_link(nil)
  end

  setup do
    {:ok, game_registry} = TTT.Game.Registry.start_link()
    {:ok, registry_pid} = TTT.Player.Registry.start_link(game_registry)
    {:ok, registry: registry_pid}
  end

  test "registry is used to greate players", %{registry: registry_pid} do
    TTT.Player.Registry.create_player(registry_pid, {"name", "password"})

    assert {"name", _pid} = TTT.Player.Registry.get_player(registry_pid, {"name", "password"})
  end

  test "remove a player if it stops", %{registry: registry_pid} do
    TTT.Player.Registry.create_player(registry_pid, {"Me", "password"})
    {"Me", pid} = TTT.Player.Registry.get_player(registry_pid, {"Me", "password"})

    Agent.stop(pid)

    assert :error == TTT.Player.Registry.get_player(registry_pid, {"Me", "password"})
  end
end
