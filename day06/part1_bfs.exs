# This is just an exercise of the digraph module and breadth-first search

defmodule UniversalOrbitMap do
  def main do
    :digraph.new()
    |> read_map()
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

  defp add_orbit([from, to], map) do
    :digraph.add_vertex(map, from)
    :digraph.add_vertex(map, to)
    :digraph.add_edge(map, from, to)
    map
  end

  defp count_orbits(map) do
    count_orbits(map, :digraph.out_neighbours(map, "COM"), [], %{}, 1)
  end

  defp count_orbits(_, [], [], _, _), do: 0

  defp count_orbits(map, [], orbiting, visited, hops) do
    count_orbits(map, orbiting, [], visited, hops + 1)
  end

  defp count_orbits(map, [u | tail], orbiting, visited, hops)
      when is_map_key(visited, u),
      do: count_orbits(map, tail, orbiting, visited, hops)

  defp count_orbits(map, [u | tail], orbiting, visited, hops) do
    hops +
      count_orbits(
        map,
        tail,
        :digraph.out_neighbours(map, u) ++ orbiting,
        Map.put(visited, u, 1),
        hops
      )
  end
end

UniversalOrbitMap.main()
|> IO.inspect(label: "number of direct and indirect orbits")
