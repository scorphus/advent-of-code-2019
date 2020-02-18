defmodule UniversalOrbitMap do
  def main do
    read_map(%{})
    |> count_orbits()
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

  defp count_orbits(map), do: count_orbits(map, Map.keys(map))

  defp count_orbits(_, []), do: 0

  defp count_orbits(map, [key | tail]) do
    count_orbits(map, key) + count_orbits(map, tail)
  end

  defp count_orbits(_, nil), do: -1

  defp count_orbits(map, key), do: 1 + count_orbits(map, map[key])
end

UniversalOrbitMap.main()
|> IO.inspect(label: "number of direct and indirect orbits")
