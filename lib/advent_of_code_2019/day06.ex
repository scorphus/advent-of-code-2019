defmodule UniversalOrbitMap do
  @moduledoc """
  Day 6 — https://adventofcode.com/2019/day/6
  """

  @doc """
  iex> ["COM)B", "B)C", "C)D", "D)E", "E)F", "B)G", "G)H", "D)I", "E)J", "J)K", "K)L"]
  iex> |> UniversalOrbitMap.part1()
  42
  """
  @spec part1(Enumerable.t()) :: integer()
  def part1(in_stream) do
    in_stream
    |> Stream.map(&parse_orbit/1)
    |> Map.new()
    |> count_orbits()
  end

  @doc """
  iex> ["COM)B", "B)C", "C)D", "D)E", "E)F", "B)G", "G)H", "D)I", "E)J", "J)K", "K)L", "K)YOU", "I)SAN"]
  iex> |> UniversalOrbitMap.part2()
  4
  """
  @spec part2(Enumerable.t()) :: integer()
  def part2(in_stream) do
    in_stream
    |> Stream.map(&parse_orbit/1)
    |> Map.new()
    |> count_transfers_from("YOU")
    |> sum_transfers_to("SAN")
  end

  @spec parse_orbit(String.t()) :: Enumerable.t()
  defp parse_orbit(line) do
    String.trim_trailing(line)
    |> String.split(")")
    |> Enum.reverse()
    |> List.to_tuple()
  end

  @spec count_orbits(map()) :: integer()
  defp count_orbits(map), do: count_orbits(map, Map.keys(map))

  @spec count_orbits(map(), Enumerable.t()) :: integer()
  defp count_orbits(_, []), do: 0

  defp count_orbits(map, [key | tail]) do
    count_orbits(map, key) + count_orbits(map, tail)
  end

  defp count_orbits(_, nil), do: -1

  defp count_orbits(map, key), do: 1 + count_orbits(map, map[key])

  @spec count_transfers_from(map(), String.t()) :: Enumerable.t()
  defp count_transfers_from(map, obj) do
    count_transfers_from(%{}, map, map[obj], 0)
  end

  @spec count_transfers_from(map(), map(), String.t(), integer()) :: {map(), map()}
  defp count_transfers_from(moves_map, map, nil, _), do: {map, moves_map}

  defp count_transfers_from(moves_map, map, obj, moves) do
    Map.put(moves_map, obj, moves)
    |> count_transfers_from(map, map[obj], moves + 1)
  end

  @spec sum_transfers_to({map(), map()}, String.t()) :: integer()
  defp sum_transfers_to({map, moves_map}, obj) do
    sum_transfers_to(moves_map, map, map[obj], 0)
  end

  @spec sum_transfers_to(map(), map(), String.t(), integer()) :: integer()
  defp sum_transfers_to(moves_map, _, obj, moves) when is_map_key(moves_map, obj) do
    moves_map[obj] + moves
  end

  defp sum_transfers_to(moves_map, map, obj, moves) do
    sum_transfers_to(moves_map, map, map[obj], moves + 1)
  end
end
