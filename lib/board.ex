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

  def mark_spot(board_pid, row, column, marker) when marker == :X or marker == :O do
    Agent.update(board_pid, fn board -> mark(board, row, column, marker) end)
  end

  def mark_spot(_, _, _, _) do
    {:error, "Invalid marker."}
  end

  defp mark({t, m, b}, row, column, marker) do
    case row do
      :top -> {change_row(t, column, marker), m, b}
      :middle -> {t, change_row(m, column, marker), b}
      :bottom -> {t, m, change_row(b, column, marker)}
    end
  end

  defp change_row({l, m, r}, column, marker) do
    case column do
      :left when l == :blank -> {marker, m, r}
      :middle when m == :blank -> {l, marker, r}
      :right when r == :blank -> {l, m, marker}
      _ -> {l, m, r}
    end
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

  def to_colums({{tl, tm, tr}, {ml, mm, mr}, {bl, bm, br}}) do
    {{tl, ml, bl}, {tm, mm, bm}, {tr, mr, br}}
  end
end
