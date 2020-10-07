defmodule SunnyWithAsteroids do
  @moduledoc """
  Day 5 — https://adventofcode.com/2019/day/5
  """

  @doc """
  iex> ["3,0,4,0,99"] |> SunnyWithAsteroids.part1()
  1
  iex> ["3,0,4,0,99"] |> SunnyWithAsteroids.part1(359)
  359
  """
  @spec part1(Enumerable.t(), integer()) :: integer()
  def part1(in_stream, system_id \\ 1) do
    in_stream
    |> Stream.map(&load_program/1)
    |> Enum.take(1)
    |> List.first()
    |> compute(0, system_id)
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
    |> Stream.map(&load_program/1)
    |> Enum.take(1)
    |> List.first()
    |> compute(0, system_id)
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

  @spec compute(map(), integer(), integer()) :: integer()
  defp compute(program, ptr, in_out) do
    program[ptr]
    |> Integer.to_string()
    |> String.pad_leading(4, "0")
    |> String.codepoints()
    |> case do
      [_, _, _, "9"] ->
        in_out

      [b, c, _, "1"] ->
        result = param(program, ptr + 1, c) + param(program, ptr + 2, b)
        compute(Map.put(program, program[ptr + 3], result), ptr + 4, in_out)

      [b, c, _, "2"] ->
        result = param(program, ptr + 1, c) * param(program, ptr + 2, b)
        compute(Map.put(program, program[ptr + 3], result), ptr + 4, in_out)

      [_, _, _, "3"] ->
        compute(Map.put(program, program[ptr + 1], in_out), ptr + 2, in_out)

      [_, c, _, "4"] ->
        compute(program, ptr + 2, param(program, ptr + 1, c))

      [b, c, _, e] ->
        {param(program, ptr + 1, c), param(program, ptr + 2, b)}
        |> jump_less_equal(e, program, ptr, in_out)
    end
  end

  @spec param(map(), integer(), String.t()) :: integer()
  defp param(program, idx, "0"), do: program[program[idx]]
  defp param(program, idx, _), do: program[idx]

  @spec jump_less_equal({integer(), integer()}, String.t(), map(), integer(), integer()) ::
          integer()
  defp jump_less_equal({p1, p2}, e, program, _, in_out)
       when (e == "5" and p1 != 0) or (e == "6" and p1 == 0),
       do: compute(program, p2, in_out)

  defp jump_less_equal(_, e, program, ptr, in_out)
       when e == "5" or e == "6",
       do: compute(program, ptr + 3, in_out)

  defp jump_less_equal({p1, p2}, e, program, ptr, in_out)
       when (e == "7" and p1 < p2) or (e == "8" and p1 == p2),
       do: compute(Map.put(program, program[ptr + 3], 1), ptr + 4, in_out)

  defp jump_less_equal(_, _, program, ptr, in_out) do
    compute(Map.put(program, program[ptr + 3], 0), ptr + 4, in_out)
  end
end
