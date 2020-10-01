defmodule CrossedWires do
  @moduledoc """
  Day 3 — https://adventofcode.com/2019/day/3
  """

  @doc """
  iex> ["R8,U5,L5,D3", "U7,R6,D4,L4"] |> CrossedWires.part1()
  6

  iex> ["R75,D30,R83,U83,L12,D49,R71,U7,L72", "U62,R66,U55,R34,D71,R55,D58,R83"]
  iex> |> CrossedWires.part1()
  159

  iex> ["R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51",
  iex>  "U98,R91,D20,R16,D67,R40,U7,R15,U6,R7"]
  iex> |> CrossedWires.part1()
  135
  """
  @spec part1(Enumerable.t()) :: integer()
  def part1(in_stream) do
    [w1, w2] =
      in_stream
      |> Stream.map(&read_wire/1)
      |> Enum.to_list()

    intersect_distances(w1, w2)
    |> Enum.min()
  end

  @doc """
  iex> ["R8,U5,L5,D3", "U7,R6,D4,L4"] |> CrossedWires.part2()
  30

  iex> ["R75,D30,R83,U83,L12,D49,R71,U7,L72", "U62,R66,U55,R34,D71,R55,D58,R83"]
  iex> |> CrossedWires.part2()
  610

  iex> ["R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51",
  iex>  "U98,R91,D20,R16,D67,R40,U7,R15,U6,R7"]
  iex> |> CrossedWires.part2()
  410
  """
  @spec part2(Enumerable.t()) :: integer()
  def part2(in_stream) do
    [w1, w2] =
      in_stream
      |> Stream.map(&read_wire/1)
      |> Enum.to_list()

    Enum.zip(intersect_steps(w1, w2, 0), intersect_steps(w2, w1, 0))
    |> Enum.map(fn {{_k1, v1}, {_k2, v2}} -> v1 + v2 end)
    |> Enum.min()
  end

  @spec read_wire(Enumerable.t()) :: Enumerable.t()
  defp read_wire(line) do
    line
    |> String.trim()
    |> String.split(",")
    |> twists_and_turns(0, 0)
  end

  @spec twists_and_turns(Enumerable.t(), integer(), integer()) :: Enumerable.t()
  defp twists_and_turns([], _, _), do: []

  defp twists_and_turns([<<bound::utf8, steps::binary>> | path], x, y) do
    {new_x, new_y} = walk(bound, String.to_integer(steps), x, y)
    [{{x, y}, {new_x, new_y}} | twists_and_turns(path, new_x, new_y)]
  end

  @spec walk(char(), integer(), integer(), integer()) :: {integer(), integer()}
  defp walk(?U, steps, x, y), do: {x, y + steps}
  defp walk(?D, steps, x, y), do: {x, y - steps}
  defp walk(?R, steps, x, y), do: {x + steps, y}
  defp walk(?L, steps, x, y), do: {x - steps, y}

  @spec intersect_distances(Enumerable.t(), Enumerable.t()) :: Enumerable.t()
  defp intersect_distances([], _), do: []

  defp intersect_distances([segment | w1], w2) do
    intersect_distances(segment, w2) ++ intersect_distances(w1, w2)
  end

  defp intersect_distances(_, []), do: []

  defp intersect_distances({a, b}, [{c, d} | w2]) do
    if intersect(a, b, c, d) and a != c do
      [manhattan_distance(a, b, c, d) | intersect_distances({a, b}, w2)]
    else
      intersect_distances({a, b}, w2)
    end
  end

  @spec intersect(Enumerable.t(), Enumerable.t(), Enumerable.t(), Enumerable.t()) ::
          Enumerable.t()
  defp intersect(a, b, c, d) do
    intersect(a, b, c) != intersect(a, b, d) and
      intersect(c, d, a) != intersect(c, d, b)
  end

  @spec intersect(Enumerable.t(), Enumerable.t(), Enumerable.t()) :: integer()
  defp intersect({ax, ay}, {bx, by}, {cx, cy}) do
    intersect((by - ay) * (cx - bx) - (bx - ax) * (cy - by))
  end

  @spec intersect(integer()) :: integer()
  defp intersect(0), do: 0
  defp intersect(v) when v > 0, do: 1
  defp intersect(_), do: 2

  @spec manhattan_distance(Enumerable.t(), Enumerable.t(), Enumerable.t(), Enumerable.t()) ::
          integer()
  defp manhattan_distance({x, _}, {x, _}, {_, y}, {_, y}), do: abs(x) + abs(y)
  defp manhattan_distance({_, y}, {_, _}, {x, _}, {_, _}), do: abs(x) + abs(y)

  @spec intersect_steps(Enumerable.t(), Enumerable.t(), Enumerable.t()) :: map()
  defp intersect_steps([], _, _), do: %{}

  defp intersect_steps([segment | w1], w2, steps) do
    intersect_steps(segment, w2, steps)
    |> Map.merge(intersect_steps(w1, w2, steps + segment_len(segment)))
  end

  defp intersect_steps(_, [], _), do: %{}

  defp intersect_steps({a, b}, [{c, d} | w2], steps) do
    if intersect(a, b, c, d) and a != c do
      %{intersect_key(a, b, c, d) => steps + segment_len(a, b, c)}
      |> Map.merge(intersect_steps({a, b}, w2, steps))
    else
      intersect_steps({a, b}, w2, steps)
    end
  end

  @spec segment_len(Enumerable.t()) :: integer()
  defp segment_len({{x, ay}, {x, by}}), do: abs(by - ay)
  defp segment_len({{ax, y}, {bx, y}}), do: abs(bx - ax)

  @spec segment_len(Enumerable.t(), Enumerable.t(), Enumerable.t()) :: integer()
  defp segment_len({x, ay}, {x, _}, {_, cy}), do: abs(cy - ay)
  defp segment_len({ax, y}, {_, y}, {cx, _}), do: abs(cx - ax)

  @spec intersect_key(Enumerable.t(), Enumerable.t(), Enumerable.t(), Enumerable.t()) ::
          Enumerable.t()
  defp intersect_key({x, _}, {x, _}, {_, y}, {_, y}), do: {x, y}
  defp intersect_key({_, y}, {_, _}, {x, _}, {_, _}), do: {x, y}
end
