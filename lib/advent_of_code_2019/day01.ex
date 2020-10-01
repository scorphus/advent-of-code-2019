defmodule RocketEquation do
  @moduledoc """
  Day 1 — https://adventofcode.com/2019/day/1
  """

  @spec part1(Enumerable.t()) :: integer()
  def part1(in_stream) do
    in_stream
    |> Stream.map(fn line ->
      line
      |> parse_module()
      |> fuel_requirements()
    end)
    |> Enum.sum()
  end

  @spec part2(Enumerable.t()) :: integer()
  def part2(in_stream) do
    in_stream
    |> Stream.map(fn line ->
      line
      |> parse_module()
      |> fuel_requirements_incremental()
    end)
    |> Enum.sum()
  end

  @spec parse_module(String.t()) :: integer()
  defp parse_module(module) do
    String.trim(module)
    |> String.to_integer()
  end

  @spec fuel_requirements(integer()) :: integer()
  defp fuel_requirements(module), do: div(module, 3) - 2

  @spec fuel_requirements_incremental(integer()) :: integer()
  defp fuel_requirements_incremental(module) when module < 9, do: 0

  defp fuel_requirements_incremental(module) do
    fuel = fuel_requirements(module)
    fuel + fuel_requirements_incremental(fuel)
  end
end
