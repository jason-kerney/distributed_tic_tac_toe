defmodule TTT.Utils do
  def pid_to_string(pid) do
    :erlang.pid_to_list(pid)
  end
end
