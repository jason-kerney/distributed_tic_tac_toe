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

  def get_location(table, row, column) do
    get_column(get_row(table, row), column)
  end

  def get_row({t, m, b}, row) do
    case row do
      :top -> t
      :middle -> m
      :bottom -> b
    end
  end

  def get_column({l, m, r}, column) do
    case column do
      :left -> l
      :middle -> m
      :right -> r
    end
  end
end
