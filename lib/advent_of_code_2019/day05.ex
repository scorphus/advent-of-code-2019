defmodule SunnyWithAsteroids do
  @moduledoc """
  Day 5 — https://adventofcode.com/2019/day/5
  """

  require AdventOfCode2019.IntcodeComputer

  @doc """
  iex> ["3,0,4,0,99"] |> SunnyWithAsteroids.part1()
  1
  iex> ["3,0,4,0,99"] |> SunnyWithAsteroids.part1(359)
  359
  """
  @spec part1(Enumerable.t(), integer()) :: integer()
  def part1(in_stream, system_id \\ 1) do
    in_stream
    |> Stream.map(&AdventOfCode2019.IntcodeComputer.load_program/1)
    |> Enum.take(1)
    |> List.first()
    |> AdventOfCode2019.IntcodeComputer.compute(0, 0, [system_id])
    |> elem(3)
  end

  @doc """
  iex> ["3,9,8,9,10,9,4,9,99,-1,8"] |> SunnyWithAsteroids.part2()
  0
  iex> ["3,9,8,9,10,9,4,9,99,-1,8"] |> SunnyWithAsteroids.part2(8)
  1
  """
  @spec part2(Enumerable.t(), integer()) :: integer()
  def part2(in_stream, system_id \\ 5) do
    in_stream
    |> Stream.map(&AdventOfCode2019.IntcodeComputer.load_program/1)
    |> Enum.take(1)
    |> List.first()
    |> AdventOfCode2019.IntcodeComputer.compute(0, 0, [system_id])
    |> elem(3)
  end
end
