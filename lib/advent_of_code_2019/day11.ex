defmodule AdventOfCode2019.SpacePolice do
  @moduledoc """
  Day 11 — https://adventofcode.com/2019/day/11
  """

  @spec part1(Enumerable.t()) :: integer
  def part1(in_stream) do
    in_stream
    |> paint(0)
    |> map_size()
  end

  @spec part2(Enumerable.t()) :: String.t()
  def part2(in_stream) do
    in_stream
    |> paint(1)
    |> draw()
    |> String.trim_trailing()
  end

  @spec paint(Enumerable.t(), integer) :: map
  def paint(in_stream, start) do
    in_stream
    |> Stream.map(&AdventOfCode2019.IntcodeComputer.load_program/1)
    |> Enum.take(1)
    |> List.first()
    |> AdventOfCode2019.PaintingRobot.paint(start)
  end

  @spec draw(map) :: String.t()
  defp draw(hull) do
    {{min_x, max_x}, {min_y, max_y}} =
      Map.keys(hull)
      |> Enum.reduce({{0, 0}, {0, 0}}, &find_limits/2)

    draw(min_x, max_y, {{min_x, max_x}, {min_y - 1, max_y}}, hull, "")
  end

  @type pos :: {integer, integer}
  @spec find_limits(pos, {pos, pos}) :: {pos, pos}
  defp find_limits({x, y}, {{min_x, max_x}, {min_y, max_y}}),
    do: {{min(min_x, x), max(max_x, x)}, {min(min_y, y), max(max_y, y)}}

  @spec draw(integer, integer, {pos, pos}, map, String.t()) :: String.t()
  defp draw(_x, min_y, {_limits_x, {min_y, _max_y}}, _hull, display), do: display

  defp draw(max_x, y, {{min_x, max_x}, _limits_y} = limits, hull, display) do
    panel = draw_panel(Map.get(hull, {max_x, y}, 0))
    draw(min_x, y - 1, limits, hull, "#{display}#{panel}\n")
  end

  defp draw(x, y, limits, hull, display) do
    panel = draw_panel(Map.get(hull, {x, y}, 0))
    draw(x + 1, y, limits, hull, "#{display}#{panel}")
  end

  @spec draw_panel(integer) :: String.t()
  defp draw_panel(0), do: "░░"
  defp draw_panel(1), do: "▓▓"
end

defmodule AdventOfCode2019.PaintingRobot do
  @moduledoc """
  Day 11 — Painting robot — https://adventofcode.com/2019/day/11
  """

  require AdventOfCode2019.IntcodeComputer

  @spec paint(map, integer) :: map
  def paint(program, start),
    do: paint(:noop, {program, 0, 0}, start, start, {0, 0}, :up, %{}, :paint)

  @type pos :: {integer, integer}
  @type state :: {map, integer, integer}
  @spec paint(atom, state, integer, integer, pos, atom, map, atom) :: map
  defp paint(:done, _state, _input, _output, _pos, _dir, hull, _action), do: hull

  defp paint(:output, state, input, output, pos, dir, hull, :paint) do
    hull = Map.put(hull, pos, output)
    {result, state, output} = AdventOfCode2019.IntcodeComputer.step(state, [input])
    paint(result, state, input, output, pos, dir, hull, :move)
  end

  defp paint(:output, state, _input, output, pos, dir, hull, :move) do
    {pos, dir} = move(output, pos, dir)
    input = Map.get(hull, pos, 0)
    {result, state, output} = AdventOfCode2019.IntcodeComputer.step(state, [input])
    paint(result, state, input, output, pos, dir, hull, :paint)
  end

  defp paint(_result, state, input, _output, pos, dir, hull, action) do
    {result, state, output} = AdventOfCode2019.IntcodeComputer.step(state, [input])
    paint(result, state, input, output, pos, dir, hull, action)
  end

  @spec move(integer, pos, atom) :: {pos, atom}
  defp move(0, {x, y}, :up), do: {{x - 1, y}, :left}
  defp move(0, {x, y}, :left), do: {{x, y - 1}, :down}
  defp move(0, {x, y}, :down), do: {{x + 1, y}, :right}
  defp move(0, {x, y}, :right), do: {{x, y + 1}, :up}
  defp move(1, {x, y}, :up), do: {{x + 1, y}, :right}
  defp move(1, {x, y}, :right), do: {{x, y - 1}, :down}
  defp move(1, {x, y}, :down), do: {{x - 1, y}, :left}
  defp move(1, {x, y}, :left), do: {{x, y + 1}, :up}
end
