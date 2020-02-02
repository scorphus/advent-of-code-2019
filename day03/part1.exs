defmodule CrossedWires do
  def main do
    intersect_distances(read_wire(), read_wire())
    |> Enum.min()
    |> IO.inspect(label: "closest intersection distance")
  end

  defp read_wire do
    IO.gets("")
    |> String.trim()
    |> String.split(",")
    |> twists_and_turns(0, 0)
  end

  defp twists_and_turns([], _, _), do: []

  defp twists_and_turns([<<bound::utf8, steps::binary>> | path], x, y) do
    {new_x, new_y} = walk(bound, String.to_integer(steps), x, y)
    [{{x, y}, {new_x, new_y}} | twists_and_turns(path, new_x, new_y)]
  end

  defp walk(?U, steps, x, y), do: {x, y + steps}
  defp walk(?D, steps, x, y), do: {x, y - steps}
  defp walk(?R, steps, x, y), do: {x + steps, y}
  defp walk(?L, steps, x, y), do: {x - steps, y}

  defp intersect_distances([], _), do: []

  defp intersect_distances([segment | w1], w2) do
    intersect_distances(segment, w2) ++ intersect_distances(w1, w2)
  end

  defp intersect_distances(_, []), do: []

  defp intersect_distances({a, b}, [{c, d} | w2]) do
    cond do
      intersect(a, b, c, d) and a != c ->
        [manhattan_distance(a, b, c, d) | intersect_distances({a, b}, w2)]

      true ->
        intersect_distances({a, b}, w2)
    end
  end

  defp intersect(a, b, c, d) do
    intersect(a, b, c) != intersect(a, b, d) and
      intersect(c, d, a) != intersect(c, d, b)
  end

  defp intersect({ax, ay}, {bx, by}, {cx, cy}) do
    intersect((by - ay) * (cx - bx) - (bx - ax) * (cy - by))
  end

  defp intersect(0), do: 0
  defp intersect(v) when v > 0, do: 1
  defp intersect(_), do: 2

  defp manhattan_distance({x, _}, {x, _}, {_, y}, {_, y}), do: abs(x) + abs(y)
  defp manhattan_distance({_, y}, {_, _}, {x, _}, {_, _}), do: abs(x) + abs(y)
end

CrossedWires.main()
