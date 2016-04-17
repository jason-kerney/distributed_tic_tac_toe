defmodule TTTTest.Player.Registry do
  use ExUnit.Case, async: true

  test "can create a registry" do
    assert {:ok, _pid} = TTT.Player.Registry.start_link(nil)
  end

  setup do
    {:ok, game_registry} = TTT.Game.Registry.start_link()
    {:ok, registry_pid} = TTT.Player.Registry.start_link(game_registry)
    {:ok, registry: registry_pid, game_registry: game_registry}
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

  test "when a player stops remove the game the player belongs to", %{registry: registry_pid, game_registry: game_registry} do
    TTT.Player.Registry.create_player(registry_pid, {"Me1", "password"})
    TTT.Player.Registry.create_player(registry_pid, {"Me2", "password"})
    {_, pid1} = player1 = TTT.Player.Registry.get_player(registry_pid, {"Me1", "password"})
    {_, pid2} = player2 = TTT.Player.Registry.get_player(registry_pid, {"Me2", "password"})
    TTT.Game.Registry.create_game(game_registry, player1, player2)

    Agent.stop(pid1)

    assert :error = TTT.Player.Registry.get_player(registry_pid, {"Me1", "password"})
    assert :no_game = TTT.Player.get_game_state(pid2)
  end
end
