defmodule AdventOfCode2019.TheNBodyProblem do
  @moduledoc """
  Day 12 — https://adventofcode.com/2019/day/12
  """

  @spec part1(Enumerable.t(), integer) :: integer
  def part1(in_stream, steps \\ 1000) do
    in_stream
    |> Stream.map(&read_moons/1)
    |> Enum.map(&start_moon/1)
    |> connect_moons([])
    |> Stream.iterate(&simulate/1)
    |> Stream.drop(steps)
    |> Enum.take(1)
    |> energy()
  end

  @spec part2(Enumerable.t()) :: integer
  def part2(in_stream) do
    in_stream
    |> Stream.map(&read_moons/1)
    |> Enum.map(&start_moon/1)
    |> connect_moons([])
    |> find_steps()
    |> Enum.reduce(&lcm/2)
  end

  @spec read_moons(Enumerable.t()) :: tuple
  defp read_moons(moon) do
    String.trim(moon)
    |> String.replace_suffix(">", "")
    |> String.split(",")
    |> Enum.map(&extract_position/1)
    |> List.to_tuple()
  end

  @spec extract_position(String.t()) :: integer
  defp extract_position(position) do
    String.split(position, "=")
    |> Enum.at(1)
    |> String.to_integer()
  end

  @spec start_moon(tuple) :: pid
  defp start_moon(position) do
    {:ok, moon} = GenServer.start_link(AdventOfCode2019.Moon, position)
    moon
  end

  @spec connect_moons(Enumerable.t(), Enumerable.t()) :: Enumerable.t()
  defp connect_moons([], seen), do: seen

  defp connect_moons([moon | tail], seen) do
    GenServer.call(moon, {:moons, seen ++ tail})
    connect_moons(tail, [moon | seen])
  end

  @spec simulate(Enumerable.t()) :: Enumerable.t()
  defp simulate(moons) do
    Enum.map(moons, &GenServer.call(&1, :gravitate))
    |> Enum.map(&GenServer.call(&1, :move))
  end

  @spec energy(Enumerable.t()) :: integer
  defp energy([moons]) do
    Stream.map(moons, &GenServer.call(&1, :energy))
    |> Enum.sum()
  end

  @spec find_steps(Enumerable.t()) :: Enumerable.t()
  defp find_steps(moons) do
    find_steps([{false, 0}, {false, 0}, {false, 0}], moons)
  end

  defp find_steps([{true, x_steps}, {true, y_steps}, {true, z_steps}], _moons) do
    [x_steps + 1, y_steps + 1, z_steps + 1]
  end

  defp find_steps(steps, moons) do
    simulate(moons)
    |> Stream.map(&GenServer.call(&1, :at_ini))
    |> Enum.reduce(fn [x, y, z], [ax, ay, az] -> [x and ax, y and ay, z and az] end)
    |> Stream.zip(steps)
    |> Enum.map(&incr_steps/1)
    |> find_steps(moons)
  end

  @spec incr_steps(tuple) :: tuple
  defp incr_steps({_, {true, steps}}), do: {true, steps}
  defp incr_steps({at_ini, {_, steps}}), do: {at_ini, steps + 1}

  @spec lcm(integer, integer) :: integer
  def lcm(0, 0), do: 0
  def lcm(a, b), do: div(a * b, gcd(a, b))

  @spec gcd(integer, integer) :: integer
  def gcd(a, 0), do: a
  def gcd(a, b), do: gcd(b, rem(a, b))
end

defmodule AdventOfCode2019.Moon do
  @moduledoc """
  Day 12 — Moon Generic Server — https://adventofcode.com/2019/day/12
  """

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
  def handle_call(:gravitate, _from, {position, velocity, ini_p, ini_v, moons}) do
    {:reply, self(), {position, gravitate(position, velocity, moons), ini_p, ini_v, moons}}
  end

  @impl true
  def handle_call(:position, _from, {position, velocity, ini_p, ini_v, moons}) do
    {:reply, position, {position, velocity, ini_p, ini_v, moons}}
  end

  @impl true
  def handle_call(:move, _from, {[x, y, z], [vx, vy, vz], ini_p, ini_v, moons}) do
    position = [x + vx, y + vy, z + vz]
    {:reply, self(), {position, [vx, vy, vz], ini_p, ini_v, moons}}
  end

  @impl true
  def handle_call(:energy, _from, {[x, y, z], [vx, vy, vz], ini_p, ini_v, moons}) do
    energy = (abs(x) + abs(y) + abs(z)) * (abs(vx) + abs(vy) + abs(vz))
    {:reply, energy, {[x, y, z], [vx, vy, vz], ini_p, ini_v, moons}}
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

  defp gravitate(_position, velocity, []), do: velocity

  defp gravitate([x, y, z], [vx, vy, vz], [moon | tail]) do
    [x2, y2, z2] = GenServer.call(moon, :position)
    gravitate([x, y, z], [gravitate(vx, x, x2), gravitate(vy, y, y2), gravitate(vz, z, z2)], tail)
  end

  defp gravitate(v, p, p2) when p < p2, do: v + 1
  defp gravitate(v, p, p2) when p > p2, do: v - 1
  defp gravitate(v, _, _), do: v
end
