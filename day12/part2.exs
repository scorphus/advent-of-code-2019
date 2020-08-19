defmodule TheNBodyProblem do
  def main do
    read_moons()
    |> Enum.map(&start_moon/1)
    |> connect_moons([])
    |> find_steps()
    |> Enum.reduce(&lcm/2)
    |> IO.inspect(label: "Steps to reach the first state that exactly matches a previous one")
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

  defp find_steps(moons) do
    find_steps([{false, 0}, {false, 0}, {false, 0}], moons)
  end

  defp find_steps([{true, x_steps}, {true, y_steps}, {true, z_steps}], _moons) do
    [x_steps + 1, y_steps + 1, z_steps + 1]
  end

  defp find_steps(steps, moons) do
    Enum.map(moons, &GenServer.call(&1, :gravity))
    Enum.map(moons, &GenServer.call(&1, :velocity))

    Stream.map(moons, &GenServer.call(&1, :at_ini))
    |> Enum.reduce(fn [x, y, z], [ax, ay, az] -> [x and ax, y and ay, z and az] end)
    |> Stream.zip(steps)
    |> Enum.map(&incr_steps/1)
    |> find_steps(moons)
  end

  defp incr_steps({_, {true, steps}}), do: {true, steps}
  defp incr_steps({at_ini, {_, steps}}), do: {at_ini, steps + 1}

  def lcm(0, 0), do: 0
  def lcm(a, b), do: div(a * b, gcd(a, b))

  def gcd(a, 0), do: a
  def gcd(0, b), do: b
  def gcd(a, b), do: gcd(b, rem(a, b))
end

defmodule Moon do
  use GenServer

  @impl true
  def init({x, y, z}) do
    {:ok, {[x, y, z], [0, 0, 0], [x, y, z], [0, 0, 0], []}}
  end

  @impl true
  def handle_call({:moons, moons}, _from, {position, velocity, ini_p, ini_v, _moons}) do
    {:reply, self(), {position, velocity, ini_p, ini_v, moons}}
  end

  @impl true
  def handle_call(:gravity, _from, {position, velocity, ini_p, ini_v, moons}) do
    {:reply, self(), {position, gravity(position, velocity, moons), ini_p, ini_v, moons}}
  end

  @impl true
  def handle_call(:position, _from, {position, velocity, ini_p, ini_v, moons}) do
    {:reply, position, {position, velocity, ini_p, ini_v, moons}}
  end

  @impl true
  def handle_call(:velocity, _from, {[x, y, z], [vx, vy, vz], ini_p, ini_v, moons}) do
    position = [x + vx, y + vy, z + vz]
    {:reply, position, {position, [vx, vy, vz], ini_p, ini_v, moons}}
  end

  @impl true
  def handle_call(:at_ini, _from, {position, velocity, ini_p, ini_v, moons}) do
    at_ini_pos =
      Stream.zip(position, ini_p)
      |> Enum.map(fn {a, b} -> a == b end)

    at_ini_vel =
      Stream.zip(position, ini_p)
      |> Enum.map(fn {a, b} -> a == b end)

    at_ini =
      Stream.zip(at_ini_pos, at_ini_vel)
      |> Enum.map(fn {a, b} -> a and b end)

    {:reply, at_ini, {position, velocity, ini_p, ini_v, moons}}
  end

  defp gravity(_position, velocity, []), do: velocity

  defp gravity([x, y, z], [vx, vy, vz], [moon | tail]) do
    [x2, y2, z2] = GenServer.call(moon, :position)
    gravity([x, y, z], [gravity(vx, x, x2), gravity(vy, y, y2), gravity(vz, z, z2)], tail)
  end

  defp gravity(v, p, p2) when p < p2, do: v + 1
  defp gravity(v, p, p2) when p > p2, do: v - 1
  defp gravity(v, _, _), do: v
end

TheNBodyProblem.main()
