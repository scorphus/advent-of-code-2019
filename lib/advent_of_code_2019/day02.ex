defmodule TwelveOhTwoProgramAlarm do
  @moduledoc """
  Day 2 — https://adventofcode.com/2019/day/2
  """

  @doc """
  iex> ["1,9,10,3,2,3,11,0,99,30,40,50"] |> TwelveOhTwoProgramAlarm.part1({9, 10})
  3500
  """
  @spec part1(Enumerable.t()) :: integer()
  def part1(in_stream, {p1, p2} \\ {12, 2}) do
    in_stream
    |> Stream.map(fn line ->
      line
      |> load_program()
      |> Map.put(1, p1)
      |> Map.put(2, p2)
      |> compute(0)
    end)
    |> Enum.to_list()
    |> List.first()
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
      |> load_program()
      |> find_pair(wanted_output, 0, 0)
    end)
    |> Enum.to_list()
    |> List.first()
  end

  @spec load_program(Enumerable.t()) :: map()
  defp load_program(line) do
    line
    |> String.trim()
    |> String.split(",")
    |> Stream.with_index()
    |> Stream.map(fn {a, b} -> {b, String.to_integer(a)} end)
    |> Map.new()
  end

  @spec compute(map(), integer()) :: integer()
  defp compute(program, opcode_idx) do
    case program[opcode_idx] do
      1 ->
        result = program[program[opcode_idx + 1]] + program[program[opcode_idx + 2]]
        compute(Map.put(program, program[opcode_idx + 3], result), opcode_idx + 4)

      2 ->
        result = program[program[opcode_idx + 1]] * program[program[opcode_idx + 2]]
        compute(Map.put(program, program[opcode_idx + 3], result), opcode_idx + 4)

      99 ->
        program[0]
    end
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
    |> compute(0)
  end
end
