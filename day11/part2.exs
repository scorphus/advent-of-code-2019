defmodule SpacePolice do
  def main do
    IO.gets("")
    |> String.trim()
    |> String.split(",")
    |> Stream.with_index()
    |> Stream.map(fn {a, b} -> {b, String.to_integer(a)} end)
    |> Map.new()
    |> PaintingRobot.paint(1)
    |> show()
  end

  defp show(hull) do
    {{min_x, max_x}, {min_y, max_y}} =
      Map.keys(hull)
      |> Enum.reduce({{0, 0}, {0, 0}}, &find_limits/2)

    draw(min_x, max_y, {{min_x, max_x}, {min_y - 1, max_y}}, hull)
  end

  defp find_limits({x, y}, {{min_x, max_x}, {min_y, max_y}}),
    do: {{min(min_x, x), max(max_x, x)}, {min(min_y, y), max(max_y, y)}}

  defp draw(_, min_y, {_, {min_y, _}}, hull), do: hull

  defp draw(max_x, y, {{min_x, max_x}, _} = limits, hull) do
    draw(Map.get(hull, {max_x, y}, 0))
    IO.write("\n")
    draw(min_x, y - 1, limits, hull)
  end

  defp draw(x, y, limits, hull) do
    draw(Map.get(hull, {x, y}, 0))
    draw(x + 1, y, limits, hull)
  end

  defp draw(0), do: IO.write(".")
  defp draw(1), do: IO.write("#")
end

SpacePolice.main()
