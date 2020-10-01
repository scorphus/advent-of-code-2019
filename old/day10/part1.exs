defmodule MonitoringStation do
  def main do
    load_belt([], 0)
    |> find_max_sights()
    |> IO.puts()
  end

  defp load_belt(belt, row), do: load_belt(IO.gets(""), belt, row)

  defp load_belt(:eof, belt, _row), do: belt

  defp load_belt(line, belt, row) do
    String.trim(line)
    |> String.graphemes()
    |> load_belt(belt, row, 0)
    |> load_belt(row + 1)
  end

  defp load_belt([], belt, _row, _col), do: belt
  defp load_belt(["." | tail], belt, row, col), do: load_belt(tail, belt, row, col + 1)

  defp load_belt(["#" | tail], belt, row, col) do
    belt = [{row, col, MapSet.new()} | belt]
    load_belt(tail, belt, row, col + 1)
  end

  defp find_max_sights(belt), do: find_max_sights(belt, belt, 0)

  defp find_max_sights([] = _asteroids, _belt, max_sights), do: max_sights

  defp find_max_sights([asteroid | tail], belt, max_sights) do
    sights = count_sights(asteroid, belt)
    find_max_sights(tail, belt, Enum.max([max_sights, sights]))
  end

  defp count_sights({_row, _col, sights}, [] = _belt), do: MapSet.size(sights)

  defp count_sights({row, col, sights}, [{row, col, _sights} | tail]) do
    count_sights({row, col, sights}, tail)
  end

  defp count_sights({row, col, sights}, [{other_row, col, _sights} | tail])
       when row > other_row do
    {row, col, MapSet.put(sights, 90)}
    |> count_sights(tail)
  end

  defp count_sights({row, col, sights}, [{_row, col, _sights} | tail]) do
    {row, col, MapSet.put(sights, 270)}
    |> count_sights(tail)
  end

  defp count_sights({row, col, sights}, [{other_row, other_col, _sights} | tail])
       when col > other_col do
    angle = angle(row, col, other_row, other_col)

    {row, col, MapSet.put(sights, angle)}
    |> count_sights(tail)
  end

  defp count_sights({row, col, sights}, [{other_row, other_col, _sights} | tail]) do
    angle = angle(row, col, other_row, other_col)

    {row, col, MapSet.put(sights, angle - 180)}
    |> count_sights(tail)
  end

  defp angle(row, col, other_row, other_col) do
    ((row - other_row) / (other_col - col))
    |> :math.atan()
    |> degrees()
  end

  defp degrees(radians), do: radians * 180 / :math.pi()
end

MonitoringStation.main()
