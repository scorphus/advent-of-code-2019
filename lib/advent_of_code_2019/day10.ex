defmodule AdventOfCode2019.MonitoringStation do
  @moduledoc """
  Day 10 — https://adventofcode.com/2019/day/10
  """

  @spec part1(Enumerable.t()) :: integer()
  def part1(in_stream) do
    in_stream
    |> Stream.with_index()
    |> Stream.map(&load_belt/1)
    |> Enum.to_list()
    |> List.flatten()
    |> find_max_sights()
  end

  @spec part2(Enumerable.t(), integer()) :: any()
  def part2(in_stream, nth \\ 200) do
    {belt, row, col} =
      in_stream
      |> Stream.with_index()
      |> Stream.map(&load_belt/1)
      |> Enum.to_list()
      |> List.flatten()
      |> Enum.reduce(Map.new(), &belt_map/2)
      |> find_best_location()

    case vaporize_from(belt, row, col, nth) do
      {_belt, {nil, nil}} -> "All asteroids already vaporized!"
      {_belt, {nth_row, nth_col}} -> nth_row + 100 * nth_col
    end
  end

  @spec load_belt(tuple()) :: Enumerable.t()
  defp load_belt({line, row}) do
    String.trim(line)
    |> String.graphemes()
    |> load_belt([], row, 0)
  end

  @spec load_belt(Enumerable.t(), Enumerable.t(), integer(), integer()) :: Enumerable.t()
  defp load_belt([], belt, _row, _col), do: belt

  defp load_belt(["." | tail], belt, row, col), do: load_belt(tail, belt, row, col + 1)

  defp load_belt(["#" | tail], belt, row, col) do
    belt = [{row, col, MapSet.new()} | belt]
    load_belt(tail, belt, row, col + 1)
  end

  ### Part 1

  @spec find_max_sights(Enumerable.t()) :: integer()
  defp find_max_sights(belt), do: find_max_sights(belt, belt, 0)

  @spec find_max_sights(Enumerable.t(), Enumerable.t(), integer()) :: integer()
  defp find_max_sights([] = _asteroids, _belt, max_sights), do: max_sights

  defp find_max_sights([asteroid | tail], belt, max_sights) do
    sights = count_sights(asteroid, belt)
    find_max_sights(tail, belt, Enum.max([max_sights, sights]))
  end

  @spec count_sights(tuple(), Enumerable.t()) :: integer()
  defp count_sights({_row, _col, sights}, [] = _belt), do: MapSet.size(sights)

  defp count_sights({row, col, sights}, [{row, col, _sights} | tail]),
    do: count_sights({row, col, sights}, tail)

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

  @spec angle(integer(), integer(), integer(), integer()) :: float()
  defp angle(row, col, other_row, other_col) do
    ((row - other_row) / (other_col - col))
    |> :math.atan()
    |> degrees()
  end

  @spec degrees(float()) :: float()
  defp degrees(radians), do: radians * 180 / :math.pi()

  ### Part 2

  defp belt_map({row, col, _neighbors}, belt),
    do: Map.put(belt, "#{row}:#{col}", {row, col, Map.new()})

  defp find_best_location(belt), do: find_best_location({0, nil}, Map.values(belt), belt)

  defp find_best_location({_max_neighbors, {row, col, _neighbors}}, [] = _asteroids, belt),
    do: {belt, row, col}

  defp find_best_location({max_neighbors, best_location}, [asteroid | tail], belt) do
    {row, col, neighbors} = add_neighbors(asteroid, Map.values(belt))
    belt = Map.put(belt, "#{row}:#{col}", {row, col, neighbors})

    Map.to_list(neighbors)
    |> length()
    |> choose_the_best(asteroid, max_neighbors, best_location)
    |> find_best_location(tail, belt)
  end

  defp choose_the_best(num_neighbors, asteroid, max_neighbors, _best_location)
       when num_neighbors > max_neighbors,
       do: {num_neighbors, asteroid}

  defp choose_the_best(_num_neighbors, _asteroid, max_neighbors, best_location),
    do: {max_neighbors, best_location}

  defp add_neighbors(asteroid, [] = _belt), do: asteroid

  defp add_neighbors({row, col, neighbors}, [{row, col, _neighbors} | tail]) do
    add_neighbors({row, col, neighbors}, tail)
  end

  defp add_neighbors({row, col, neighbors}, [{other_row, col, _neighbors} | tail])
       when row > other_row do
    neighbors = add_neighbor(neighbors, other_row, col, 0, row - other_row)
    add_neighbors({row, col, neighbors}, tail)
  end

  defp add_neighbors({row, col, neighbors}, [{other_row, col, _neighbors} | tail]) do
    neighbors = add_neighbor(neighbors, other_row, col, 180, other_row - row)
    add_neighbors({row, col, neighbors}, tail)
  end

  defp add_neighbors({row, col, neighbors}, [{other_row, other_col, _neighbors} | tail])
       when col <= other_col do
    angle = angle(row, col, other_row, other_col)
    dist = dist(row, col, other_row, other_col)
    neighbors = add_neighbor(neighbors, other_row, other_col, 90 - angle, dist)
    add_neighbors({row, col, neighbors}, tail)
  end

  defp add_neighbors({row, col, neighbors}, [{other_row, other_col, _neighbors} | tail]) do
    angle = angle(row, col, other_row, other_col)
    dist = dist(row, col, other_row, other_col)
    neighbors = add_neighbor(neighbors, other_row, other_col, 270 - angle, dist)
    add_neighbors({row, col, neighbors}, tail)
  end

  defp dist(row, col, other_row, other_col) do
    (:math.pow(row - other_row, 2) + :math.pow(col - other_col, 2))
    |> :math.sqrt()
  end

  defp add_neighbor(neighbors, new_row, new_col, angle, new_dist)
       when not is_map_key(neighbors, angle),
       do: Map.put(neighbors, angle, {new_row, new_col, new_dist})

  defp add_neighbor(neighbors, new_row, new_col, angle, new_dist) do
    {_row, _col, dist} = neighbors[angle]
    add_neighbor(neighbors, new_row, new_col, angle, new_dist, dist)
  end

  defp add_neighbor(neighbors, new_row, new_col, angle, new_dist, dist)
       when new_dist < dist,
       do: Map.put(neighbors, angle, {new_row, new_col, new_dist})

  defp add_neighbor(neighbors, _new_row, _new_col, _angle, _new_dist, _dist),
    do: neighbors

  defp vaporize_from(belt, row, col, total) do
    {row, col, targets} = belt["#{row}:#{col}"]
    vaporize_from([], belt, targets, row, col, total)
  end

  defp vaporize_from([], belt, targets, _row, _col, _total) when targets == %{},
    do: {belt, {nil, nil}}

  defp vaporize_from([], belt, targets, row, col, total) do
    Enum.sort(targets)
    |> vaporize_from(belt, targets, row, col, total)
  end

  defp vaporize_from(
         [{_angle, {target_row, target_col, _dist}} | _tail],
         belt,
         _targets,
         _row,
         _col,
         total
       )
       when total < 2 do
    {_target, belt} = Map.pop!(belt, "#{target_row}:#{target_col}")
    {belt, {target_row, target_col}}
  end

  defp vaporize_from(
         [{angle, {target_row, target_col, _dist}} | tail],
         belt,
         targets,
         row,
         col,
         total
       ) do
    {belt, targets} = vaporize(belt, target_row, target_col, targets, angle)
    vaporize_from(tail, belt, targets, row, col, total - 1)
  end

  defp vaporize(belt, row, col, targets, angle) do
    {{_row, _col, neighbors}, belt} = Map.pop!(belt, "#{row}:#{col}")

    case neighbors[angle] do
      nil ->
        {belt, Map.delete(targets, angle)}

      next_target ->
        {belt, Map.replace!(targets, angle, next_target)}
    end
  end
end
