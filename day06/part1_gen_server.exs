# This is just an exercise of the GenServer behaviour

defmodule OrbitCounter do
  use GenServer

  @impl true
  def init({map, key}) do
    {:ok, {map, key, 0}}
  end

  @impl true
  def handle_cast(:count, {map, key, orbits}) do
    {:noreply, {map, key, count_orbits(map, key, orbits)}}
  end

  @impl true
  def handle_call(:orbits, _from, {map, key, orbits}) do
    {:reply, orbits, {map, key, orbits}}
  end

  defp count_orbits(_, nil, orbits), do: orbits - 1

  defp count_orbits(map, key, orbits), do: count_orbits(map, map[key], orbits + 1)
end

defmodule UniversalOrbitMap do
  def main do
    read_map(%{})
    |> count_orbits()
    |> sum_orbits(0)
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

  defp count_orbits(_, []), do: []

  defp count_orbits(map, [key | tail]) do
    {:ok, pid} = GenServer.start(OrbitCounter, {map, key})
    GenServer.cast(pid, :count)
    count_orbits(map, tail) ++ [pid]
  end

  defp sum_orbits([], orbits), do: orbits

  defp sum_orbits([pid | tail], orbits) do
    sum_orbits(tail, orbits + GenServer.call(pid, :orbits))
  end
end

UniversalOrbitMap.main()
|> IO.inspect(label: "number of direct and indirect orbits")
