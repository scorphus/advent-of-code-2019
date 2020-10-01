defmodule TheNBodyProblem do
  def main do
    read_moons()
    |> Enum.map(&start_moon/1)
    |> connect_moons([])
    |> simulate()
    |> IO.inspect(label: "Total energy in the system")
  end

  def read_moons do
    IO.gets("")
    |> read_moons([])
  end

  defp read_moons(:eof, moons), do: moons

  defp read_moons(moon, moons) do
    moon =
      String.trim(moon)
      |> String.replace_suffix(">", "")
      |> String.split(",")
      |> Enum.map(&extract_position/1)
      |> List.to_tuple()

    IO.gets("")
    |> read_moons([moon | moons])
  end

  defp extract_position(position) do
    String.split(position, "=")
    |> Enum.at(1)
    |> String.to_integer()
  end

  defp start_moon(position) do
    {:ok, moon} = GenServer.start_link(Moon, position)
    moon
  end

  defp connect_moons([], seen), do: seen

  defp connect_moons([moon | tail], seen) do
    GenServer.call(moon, {:moons, seen ++ tail})
    connect_moons(tail, [moon | seen])
  end

  defp simulate(moons) do
    System.argv()
    |> List.first()
    |> String.to_integer()
    |> simulate(moons)
    |> Stream.map(&GenServer.call(&1, :energy))
    |> Enum.sum()
  end

  defp simulate(0, moons), do: moons

  defp simulate(steps, moons) do
    Enum.map(moons, &GenServer.call(&1, :gravity))
    Enum.map(moons, &GenServer.call(&1, :velocity))
    simulate(steps - 1, moons)
  end
end

defmodule Moon do
  use GenServer

  @impl true
  def init({x, y, z}) do
    {:ok, {{x, y, z}, {0, 0, 0}, []}}
  end

  @impl true
  def handle_call({:moons, moons}, _from, {position, velocity, _moons}) do
    {:reply, self(), {position, velocity, moons}}
  end

  @impl true
  def handle_call(:gravity, _from, {position, velocity, moons}) do
    {:reply, self(), {position, gravity(position, velocity, moons), moons}}
  end

  @impl true
  def handle_call(:position, _from, {position, velocity, moons}) do
    {:reply, position, {position, velocity, moons}}
  end

  @impl true
  def handle_call(:velocity, _from, {{x, y, z}, {vx, vy, vz}, moons}) do
    position = {x + vx, y + vy, z + vz}
    {:reply, position, {position, {vx, vy, vz}, moons}}
  end

  @impl true
  def handle_call(:energy, _from, {{x, y, z}, {vx, vy, vz}, moons}) do
    energy = (abs(x) + abs(y) + abs(z)) * (abs(vx) + abs(vy) + abs(vz))
    {:reply, energy, {{x + vx, y + vy, z + vz}, {vx, vy, vz}, moons}}
  end

  defp gravity(_position, velocity, []), do: velocity

  defp gravity({x, y, z}, {vx, vy, vz}, [moon | tail]) do
    {x2, y2, z2} = GenServer.call(moon, :position)
    gravity({x, y, z}, {gravity(vx, x, x2), gravity(vy, y, y2), gravity(vz, z, z2)}, tail)
  end

  defp gravity(v, p, p2) when p < p2, do: v + 1
  defp gravity(v, p, p2) when p > p2, do: v - 1
  defp gravity(v, _, _), do: v
end

TheNBodyProblem.main()
