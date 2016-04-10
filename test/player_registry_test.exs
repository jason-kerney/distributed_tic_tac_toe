defmodule TTTTest.Player.Registry do
  use ExUnit.Case, async: true

  test "can create a registry" do
    assert {:ok, _pid} = TTT.Player.Registry.start_link()
  end

  setup do
    {:ok, registry_pid} = TTT.Player.Registry.start_link()
    {:ok, registry: registry_pid}
  end

  test "registry is used to greate players", %{registry: registry_pid} do
    TTT.Player.Registry.create_player(registry_pid, {"name", "password"})

    assert {"name", _pid} = TTT.Player.Registry.get_player(registry_pid, {"name", "password"})
  end
end
