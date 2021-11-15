defmodule AdventOfCode2019.OxygenSystem do
  @moduledoc """
  Day 15 — https://adventofcode.com/2019/day/15
  """

  require AdventOfCode2019.IntcodeComputer

  @spec part1(Enumerable.t()) :: integer
  def part1(in_stream) do
    in_stream
    |> load_program()
    |> locate()
    |> List.first()
  end

  @spec part2(Enumerable.t()) :: integer
  def part2(in_stream) do
    in_stream
    |> load_program()
    |> locate()
    |> List.last()
  end

  @spec load_program(Enumerable.t()) :: map
  defp load_program(in_stream) do
    in_stream
    |> Stream.map(&AdventOfCode2019.IntcodeComputer.load_program/1)
    |> Enum.take(1)
    |> List.first()
  end

  @spec locate(map) :: list
  defp locate(program) do
    locate({:noop, {program, 0, 0}, nil}, {0, 0}, [], nil, 1, :fore, %{{0, 0} => []}, 0)
  end

  @type position :: {integer, integer}
  @spec locate(
          {atom, {map, integer, integer}, integer | nil},
          position,
          list,
          list | nil,
          integer,
          atom,
          map,
          integer
        ) :: list
  defp locate({:output, state, 0}, {x, y}, path, oxy, move, _dir, area, len) do
    {dx, dy} = fore(move)
    area = Map.put(area, {x + dx, y + dy}, [])
    {move, dir} = turn({x, y}, path, move, area)

    AdventOfCode2019.IntcodeComputer.step(state, [move])
    |> locate({x, y}, path, oxy, move, dir, area, len)
  end

  defp locate({:output, state, _loc}, {x, y}, [head | path], oxy, move, :back, area, len) do
    {dx, dy} = fore(move)
    pos = {x + dx, y + dy}
    {move, dir} = turn(pos, path, head, area)

    AdventOfCode2019.IntcodeComputer.step(state, [move])
    |> locate(pos, path, oxy, move, dir, area, len)
  end

  defp locate({:output, _state, 2} = data, pos, path, nil, move, :fore, area, _len) do
    locate(data, pos, path, [move | path], move, :fore, area, length(path) + 1)
  end

  defp locate({:output, state, _loc}, {x, y}, path, oxy, move, :fore, area, len) do
    {dx, dy} = fore(move)
    pos = {x + dx, y + dy}

    AdventOfCode2019.IntcodeComputer.step(state, [move])
    |> locate(pos, [move | path], oxy, move, :fore, Map.put(area, pos, path), len)
  end

  defp locate({:done, _state, nil}, _pos, _path, oxy, _move, :stop, area, len) do
    min =
      Map.values(area)
      |> Enum.max_by(fn path -> length(path) end)
      |> Enum.reverse()
      |> deoverlap(Enum.reverse(oxy))

    [len, min]
  end

  defp locate({_result, state, _loc}, pos, path, oxy, move, dir, area, len) do
    AdventOfCode2019.IntcodeComputer.step(state, [move])
    |> locate(pos, path, oxy, move, dir, area, len)
  end

  @spec fore(1 | 2 | 3 | 4) :: {-1 | 0 | 1, -1 | 0 | 1}
  defp fore(1), do: {0, 1}
  defp fore(2), do: {0, -1}
  defp fore(3), do: {-1, 0}
  defp fore(4), do: {1, 0}

  @spec fore(1 | 2 | 3 | 4, position) :: position
  defp fore(move, {x, y}) do
    fore(move)
    |> (fn {dx, dy} -> {x + dx, y + dy} end).()
  end

  @spec turn(position, list, integer, map) :: {integer, atom}
  defp turn(pos, path, move, area) do
    turn(move)
    |> fore(pos)
    |> turn(pos, path, turn(move), area, 1)
  end

  @spec turn(1 | 2 | 3 | 4) :: 1 | 2 | 3 | 4
  defp turn(1), do: 3
  defp turn(2), do: 4
  defp turn(3), do: 2
  defp turn(4), do: 1

  @spec turn(position, position, list, integer, map, integer) :: {integer, atom}
  defp turn(_new_pos, _pos, [], _move, _area, turns) when turns > 4, do: {0, :stop}

  defp turn(_new_pos, _pos, [move | _path], _move, _area, 4), do: {back(move), :back}

  defp turn(new_pos, pos, path, move, area, turns) when is_map_key(area, new_pos) do
    turn(move)
    |> fore(pos)
    |> turn(pos, path, turn(move), area, turns + 1)
  end

  defp turn(_new_pos, _pos, _path, move, _area, _turns), do: {move, :fore}

  @spec back(1 | 2 | 3 | 4) :: 1 | 2 | 3 | 4
  defp back(1), do: 2
  defp back(2), do: 1
  defp back(3), do: 4
  defp back(4), do: 3

  @spec deoverlap(list, list) :: integer
  defp deoverlap([same | longest], [same | oxy]), do: deoverlap(longest, oxy)
  defp deoverlap(longest, oxy), do: length(longest) + length(oxy) + 1
end
