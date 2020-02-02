defmodule CrossedWires do
  def main do
    {w1, w2} = {read_wire(), read_wire()}

    Enum.zip(intersect_steps(w1, w2, 0), intersect_steps(w2, w1, 0))
    |> Enum.map(fn {{_, s1}, {_, s2}} -> s1 + s2 end)
    |> Enum.min()
    |> IO.inspect(label: "fewest combined steps")
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

  defp intersect_steps([], _, _), do: %{}

  defp intersect_steps([segment | w1], w2, steps) do
    intersect_steps(segment, w2, steps)
    |> Map.merge(intersect_steps(w1, w2, steps + segment_len(segment)))
  end

  defp intersect_steps(_, [], _), do: %{}

  defp intersect_steps({a, b}, [{c, d} | w2], steps) do
    cond do
      intersect(a, b, c, d) and a != c ->
        %{intersect_key(a, b, c, d) => steps + segment_len(a, b, c)}
        |> Map.merge(intersect_steps({a, b}, w2, steps))

      true ->
        intersect_steps({a, b}, w2, steps)
    end
  end

  defp segment_len({{x, ay}, {x, by}}), do: abs(by - ay)
  defp segment_len({{ax, y}, {bx, y}}), do: abs(bx - ax)
  defp segment_len({x, ay}, {x, _}, {_, cy}), do: abs(cy - ay)
  defp segment_len({ax, y}, {_, y}, {cx, _}), do: abs(cx - ax)

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

  defp intersect_key({x, _}, {x, _}, {_, y}, {_, y}), do: {x, y}
  defp intersect_key({_, y}, {_, _}, {x, _}, {_, _}), do: {x, y}
end

CrossedWires.main()
