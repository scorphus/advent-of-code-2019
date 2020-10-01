defmodule CarePackage do
  def main do
    IO.gets("")
    |> String.trim()
    |> String.split(",")
    |> Stream.with_index()
    |> Stream.map(fn {a, b} -> {b, String.to_integer(a)} end)
    |> Map.new()
    |> Map.put(0, 2)
    |> play()
    |> IO.inspect(label: "Score after the last block is broken")
  end

  defp play(program), do: play({:noop, {program, 0, 0}, nil}, [], 0, 0, 0, 0)

  defp play({:output, state, score}, [0, -1], pad, ball, input, _score) do
    Computer.compute(state, input)
    |> play([], pad, ball, input, score)
  end

  defp play({:output, state, 3}, [_y, pad], _pad, ball, input, score) do
    Computer.compute(state, input)
    |> play([], pad, ball, joystick(pad, ball), score)
  end

  defp play({:output, state, 4}, [_y, ball], pad, _ball, input, score) do
    Computer.compute(state, input)
    |> play([], pad, ball, joystick(pad, ball), score)
  end

  defp play({:output, state, _id}, [_y, _x], pad, ball, input, score) do
    Computer.compute(state, input)
    |> play([], pad, ball, input, score)
  end

  defp play({:output, state, yx}, tile, pad, ball, input, score) do
    Computer.compute(state, input)
    |> play([yx | tile], pad, ball, input, score)
  end

  defp play({:noop, state, nil}, tile, pad, ball, input, score) do
    Computer.compute(state, input)
    |> play(tile, pad, ball, input, score)
  end

  defp play(_, _tile, _pad, _ball, _input, score), do: score

  defp joystick(x, x), do: 0
  defp joystick(pad, ball) when pad < ball, do: 1
  defp joystick(_, _), do: -1
end

CarePackage.main()
