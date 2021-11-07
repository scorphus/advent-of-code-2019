defmodule TwelveOhTwoProgramAlarm do
  @moduledoc """
  Day 2 — https://adventofcode.com/2019/day/2
  """

  require AdventOfCode2019.IntcodeComputer

  @doc """
  iex> ["1,9,10,3,2,3,11,0,99,30,40,50"] |> TwelveOhTwoProgramAlarm.part1({9, 10})
  3500
  """
  @spec part1(Enumerable.t()) :: integer()
  def part1(in_stream, {p1, p2} \\ {12, 2}) do
    in_stream
    |> Stream.map(fn line ->
      line
      |> AdventOfCode2019.IntcodeComputer.load_program()
      |> Map.put(1, p1)
      |> Map.put(2, p2)
      |> AdventOfCode2019.IntcodeComputer.compute(0, 0)
    end)
    |> Enum.take(1)
    |> List.first()
    |> elem(0)
    |> Map.get(0)
  end

  @doc """
  iex> ["1,9,10,3,2,3,11,0,99,30,40,50"] |> TwelveOhTwoProgramAlarm.part2(200)
  3
  """
  @spec part2(Enumerable.t()) :: integer()
  def part2(in_stream, wanted_output \\ 19_690_720) do
    in_stream
    |> Stream.map(fn line ->
      line
      |> AdventOfCode2019.IntcodeComputer.load_program()
      |> find_pair(wanted_output, 0, 0)
    end)
    |> Enum.to_list()
    |> List.first()
  end

  @spec find_pair(map(), integer(), integer(), integer()) :: integer()
  defp find_pair(program, wanted_output, noun, 100) do
    find_pair(program, wanted_output, noun + 1, 0)
  end

  defp find_pair(program, wanted_output, noun, verb) do
    if compute(program, noun, verb) == wanted_output do
      100 * noun + verb
    else
      find_pair(program, wanted_output, noun, verb + 1)
    end
  end

  @spec compute(map(), integer(), integer()) :: integer()
  defp compute(program, noun, verb) do
    Map.put(program, 1, noun)
    |> Map.put(2, verb)
    |> AdventOfCode2019.IntcodeComputer.compute(0, 0)
    |> elem(0)
    |> Map.get(0)
  end
end
