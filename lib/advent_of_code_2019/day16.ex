defmodule AdventOfCode2019.FlawedFrequencyTransmission do
  @moduledoc """
  Day 16 — https://adventofcode.com/2019/day/16
  """

  @base_pattern [0, 1, 0, -1]

  @spec part1(Enumerable.t()) :: binary
  def part1(in_stream) do
    in_stream
    |> read_input_signal()
    |> repeat_phases(100)
    |> Stream.take(8)
    |> Enum.join()
  end

  @spec part2(Enumerable.t()) :: binary
  def part2(in_stream) do
    input_signal =
      in_stream
      |> read_input_signal()

    offset =
      Enum.slice(input_signal, 0, 7)
      |> Enum.join()
      |> String.to_integer()

    repeat_phases(input_signal, 100, 10_000 * length(input_signal), offset)
    |> Stream.take(8)
    |> Enum.join()
  end

  @spec read_input_signal(Enumerable.t()) :: list
  defp read_input_signal(in_stream) do
    in_stream
    |> Enum.take(1)
    |> List.first()
    |> String.trim()
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
  end

  defp repeat_phases(input_signal, phases) do
    Enum.reduce(1..phases, input_signal, &run_phases/2)
  end

  defp repeat_phases(input_signal, phases, size, offset) do
    Stream.cycle(input_signal)
    |> Stream.drop(offset)
    |> Enum.take(size - offset)
    |> Stream.iterate(&run_phases/1)
    |> Enum.at(phases)
  end

  defp run_phases(_phase, input_signal) do
    Stream.transform(1..length(input_signal), input_signal, &output_signal/2)
    |> Enum.to_list()
  end

  defp run_phases(input_signal) do
    {input_signal, _} = output_signal(input_signal)
    input_signal
  end

  defp output_signal(i, input_signal) do
    {[
       Stream.zip(input_signal, repeat_pattern(i))
       |> Stream.map(fn {a, b} -> a * b end)
       |> Enum.sum()
       |> rem(10)
       |> abs()
     ], input_signal}
  end

  defp output_signal([n]), do: {[n], n}

  defp output_signal([n | tail]) do
    {tail, sum} = output_signal(tail)
    {[rem(n + sum, 10) | tail], n + sum}
  end

  defp repeat_pattern(n) do
    Stream.unfold({1, n, @base_pattern}, fn
      {_, _, []} -> nil
      {n, n, [head | tail]} -> {head, {1, n, tail}}
      {i, n, [head | tail]} -> {head, {i + 1, n, [head | tail]}}
    end)
    |> Stream.cycle()
    |> Stream.drop(1)
  end
end
