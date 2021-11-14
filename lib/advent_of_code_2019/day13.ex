defmodule AdventOfCode2019.CarePackage do
  @moduledoc """
  Day 13 — https://adventofcode.com/2019/day/13
  """

  require AdventOfCode2019.IntcodeComputer

  @spec part1(Enumerable.t()) :: integer
  def part1(in_stream) do
    in_stream
    |> load_program()
    |> play()
    |> List.first()
  end

  @spec part2(Enumerable.t()) :: integer
  def part2(in_stream) do
    in_stream
    |> load_program()
    |> Map.put(0, 2)
    |> play()
    |> List.last()
  end

  defp load_program(in_stream) do
    in_stream
    |> Stream.map(&AdventOfCode2019.IntcodeComputer.load_program/1)
    |> Enum.take(1)
    |> List.first()
  end

  @spec play(map) :: list
  defp play(program), do: play({:noop, {program, 0, 0}, nil}, [], 0, 0, 0, 0, 0)

  @spec play(tuple, list, integer, integer, integer, integer, integer) :: list
  defp play({:done, _state, _id}, _tile, count, _pad, _ball, _input, score), do: [count, score]

  defp play({:output, state, score}, [0, -1], count, pad, ball, input, _score) do
    AdventOfCode2019.IntcodeComputer.step(state, [input])
    |> play([], count, pad, ball, input, score)
  end

  defp play({:output, state, 2}, [_y, _x], count, pad, ball, input, score) do
    AdventOfCode2019.IntcodeComputer.step(state, [input])
    |> play([], count + 1, pad, ball, input, score)
  end

  defp play({:output, state, 3}, [_y, pad], count, _pad, ball, input, score) do
    AdventOfCode2019.IntcodeComputer.step(state, [input])
    |> play([], count, pad, ball, joystick(pad, ball), score)
  end

  defp play({:output, state, 4}, [_y, ball], count, pad, _ball, input, score) do
    AdventOfCode2019.IntcodeComputer.step(state, [input])
    |> play([], count, pad, ball, joystick(pad, ball), score)
  end

  defp play({:output, state, _id}, [_y, _x], count, pad, ball, input, score) do
    AdventOfCode2019.IntcodeComputer.step(state, [input])
    |> play([], count, pad, ball, input, score)
  end

  defp play({:output, state, yx}, tile, count, pad, ball, input, score) do
    AdventOfCode2019.IntcodeComputer.step(state, [input])
    |> play([yx | tile], count, pad, ball, input, score)
  end

  defp play({_result, state, _id}, tile, count, pad, ball, input, score) do
    AdventOfCode2019.IntcodeComputer.step(state, [input])
    |> play(tile, count, pad, ball, input, score)
  end

  @spec joystick(integer, integer) :: integer
  defp joystick(x, x), do: 0
  defp joystick(pad, ball) when pad < ball, do: 1
  defp joystick(_, _), do: -1
end
