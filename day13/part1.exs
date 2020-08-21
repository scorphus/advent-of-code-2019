defmodule CarePackage do
  def main do
    IO.gets("")
    |> String.trim()
    |> String.split(",")
    |> Stream.with_index()
    |> Stream.map(fn {a, b} -> {b, String.to_integer(a)} end)
    |> Map.new()
    |> play()
    |> IO.inspect(label: "Number of block tiles on the screen")
  end

  defp play(program), do: play({:noop, {program, 0, 0}, nil}, [], 0)

  defp play({:output, state, 2}, [_y, _x], count) do
    Computer.compute(state)
    |> play([], count + 1)
  end

  defp play({:output, state, _id}, [_y, _x], count) do
    Computer.compute(state)
    |> play([], count)
  end

  defp play({:output, state, yx}, tile, count) do
    Computer.compute(state)
    |> play([yx | tile], count)
  end

  defp play({:noop, state, nil}, tile, count) do
    Computer.compute(state)
    |> play(tile, count)
  end

  defp play(_, _tile, count), do: count
end

CarePackage.main()
