defmodule AdventOfCode2019.SpaceImageFormat do
  @moduledoc """
  Day 8 — https://adventofcode.com/2019/day/8
  """

  @doc """
  iex> ["123456789012"] |> AdventOfCode2019.SpaceImageFormat.part1()
  4
  """
  @spec part1(Enumerable.t()) :: integer()
  def part1(in_stream) do
    in_stream
    |> Stream.map(fn line ->
      line
      |> read_image_data()
      |> Stream.map(fn l ->
        [Enum.count(l, &(&1 == "0")), Enum.count(l, &(&1 == "1")) * Enum.count(l, &(&1 == "2"))]
      end)
      |> Enum.min_by(fn [a, _] -> a end)
    end)
    |> Enum.take(1)
    |> Enum.at(0)
    |> Enum.at(1)
  end

  @doc """
  iex> ["123456789012"] |> AdventOfCode2019.SpaceImageFormat.part2()
  "▓▓                ░░▓▓  "
  iex> [Enum.join((for _ <- 1..151, do: 1), "")] |> AdventOfCode2019.SpaceImageFormat.part2()
  "▓▓"
  iex> [Enum.join((for _ <- 1..151, do: 2), "")] |> AdventOfCode2019.SpaceImageFormat.part2()
  "  "
  """
  @spec part2(Enumerable.t()) :: String.t()
  def part2(in_stream) do
    in_stream
    |> Stream.map(fn line ->
      line
      |> read_image_data()
      |> Enum.reduce(&merge_layers/2)
      |> Stream.chunk_every(25)
      |> Enum.map_join("\n", &join_row/1)
    end)
    |> Enum.take(1)
    |> Enum.at(0)
  end

  @spec read_image_data(Enumerable.t()) :: Enumerable.t()
  defp read_image_data(line) do
    line
    |> String.trim()
    |> String.graphemes()
    |> Stream.chunk_every(25 * 6)
  end

  @spec merge_layers(String.t(), String.t()) :: Enumerable.t()
  defp merge_layers(back, fore) do
    Enum.zip(back, fore)
    |> Enum.map(&merge_pixels/1)
  end

  @spec merge_pixels(tuple()) :: String.t()
  defp merge_pixels({back, "2"}), do: back
  defp merge_pixels({_, fore}), do: fore

  @spec join_row(Enumerable.t()) :: String.t()
  defp join_row(row), do: Enum.map_join(row, &paint_pixels/1)

  @spec paint_pixels(String.t()) :: String.t()
  defp paint_pixels("0"), do: "░░"
  defp paint_pixels("1"), do: "▓▓"
  defp paint_pixels(_), do: "  "
end
