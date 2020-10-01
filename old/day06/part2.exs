defmodule UniversalOrbitMap do
  def main do
    read_map(%{})
    |> count_transfers_from("YOU")
    |> sum_transfers_to("SAN")
  end

  defp read_map(map) do
    IO.gets("")
    |> read_map(map)
  end

  defp read_map(:eof, map), do: map

  defp read_map(orbit, map) do
    String.trim(orbit)
    |> String.split(")")
    |> add_orbit(map)
    |> read_map()
  end

  defp add_orbit([from, to], map), do: Map.put(map, to, from)

  defp count_transfers_from(map, obj) do
    count_transfers_from(%{}, map, map[obj], 0)
  end

  defp count_transfers_from(moves_map, map, nil, _), do: {map, moves_map}

  defp count_transfers_from(moves_map, map, obj, moves) do
    Map.put(moves_map, obj, moves)
    |> count_transfers_from(map, map[obj], moves + 1)
  end

  defp sum_transfers_to({map, moves_map}, obj) do
    sum_transfers_to(moves_map, map, map[obj], 0)
  end

  defp sum_transfers_to(_, _, nil, _), do: -1

  defp sum_transfers_to(moves_map, _, obj, moves) when is_map_key(moves_map, obj) do
    moves_map[obj] + moves
  end

  defp sum_transfers_to(moves_map, map, obj, moves) do
    sum_transfers_to(moves_map, map, map[obj], moves + 1)
  end
end

UniversalOrbitMap.main()
|> IO.inspect(label: "number of direct and indirect orbits")
