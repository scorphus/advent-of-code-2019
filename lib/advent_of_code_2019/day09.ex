defmodule AdventOfCode2019.SensorBoost do
  @moduledoc """
  Day 9 — https://adventofcode.com/2019/day/9
  """

  require AdventOfCode2019.IntcodeComputer

  @doc """
  iex> ["109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99"] |> AdventOfCode2019.SensorBoost.part1()
  99
  iex> ["1102,34915192,34915192,7,4,7,99,0"] |> AdventOfCode2019.SensorBoost.part1()
  1219070632396864
  iex> ["104,1125899906842624,99"] |> AdventOfCode2019.SensorBoost.part1()
  1125899906842624
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
  iex> ["109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99"] |> AdventOfCode2019.SensorBoost.part2()
  99
  iex> ["1102,34915192,34915192,7,4,7,99,0"] |> AdventOfCode2019.SensorBoost.part2()
  1219070632396864
  iex> ["104,1125899906842624,99"] |> AdventOfCode2019.SensorBoost.part2()
  1125899906842624
  """
  @spec part2(Enumerable.t()) :: integer()
  def part2(in_stream) do
    part1(in_stream, 2)
  end
end
