defmodule TTT.Board do
  @empty_row {:blank, :blank, :blank}
  @empty_table {@empty_row, @empty_row, @empty_row}

  def empty_row() do
    @empty_row
  end

  def empty_table() do
    @empty_table
  end

  def start_link do
    empty = @empty_table
    Agent.start_link(fn -> empty end)
  end

  def get_board(board_pid) do
    Agent.get(board_pid, fn board -> board end)
  end
end
