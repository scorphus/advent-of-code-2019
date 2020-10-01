defmodule OxygenSystem do
  def main do
    IO.gets("")
    |> String.trim()
    |> String.split(",")
    |> Stream.with_index()
    |> Stream.map(fn {a, b} -> {b, String.to_integer(a)} end)
    |> Map.new()
    |> locate()
    |> IO.inspect(label: "Fewest number of movement commands to reach oxygen")
  end

  defp locate(program) do
    locate({:noop, {program, 0, 0}, nil}, {0, 0}, [], 1, :forward, %{{0, 0} => 1})
  end

  defp locate({:output, state, 0}, {x, y}, path, move, _dir, area) do
    {dx, dy} = forward(move)
    area = Map.put(area, {x + dx, y + dy}, 0)
    {move, dir} = turn({x, y}, path, move, area)

    Computer.compute(state, move)
    |> locate({x, y}, path, move, dir, area)
  end

  defp locate({:output, state, 1}, {x, y}, [head | path], move, :backward, area) do
    {dx, dy} = forward(move)
    pos = {x + dx, y + dy}
    {move, dir} = turn(pos, path, head, area)

    Computer.compute(state, move)
    |> locate(pos, path, move, dir, area)
  end

  defp locate({:output, state, 1}, {x, y}, path, move, :forward, area) do
    {dx, dy} = forward(move)
    pos = {x + dx, y + dy}

    Computer.compute(state, move)
    |> locate(pos, [move | path], move, :forward, Map.put(area, pos, 1))
  end

  defp locate({:output, _state, 2}, _pos, path, _move, _dir, _area), do: length(path) + 1

  defp locate({_, state, nil}, pos, path, move, dir, area) do
    Computer.compute(state, move)
    |> locate(pos, path, move, dir, area)
  end

  defp forward(1), do: {0, 1}
  defp forward(2), do: {0, -1}
  defp forward(3), do: {-1, 0}
  defp forward(4), do: {1, 0}

  defp forward(move, {x, y}) do
    forward(move)
    |> (fn {dx, dy} -> {x + dx, y + dy} end).()
  end

  defp turn(pos, path, move, area) do
    turn(move)
    |> forward(pos)
    |> turn(pos, path, turn(move), area, 1)
  end

  defp turn(1), do: 3
  defp turn(2), do: 4
  defp turn(3), do: 2
  defp turn(4), do: 1

  defp turn(_new_pos, _pos, [move | _path], _move, _area, 4), do: {backward(move), :backward}

  defp turn(new_pos, pos, path, move, area, turns) when is_map_key(area, new_pos) do
    turn(move)
    |> forward(pos)
    |> turn(pos, path, turn(move), area, turns + 1)
  end

  defp turn(_new_pos, _pos, _path, move, _area, _turns), do: {move, :forward}

  defp backward(1), do: 2
  defp backward(2), do: 1
  defp backward(3), do: 4
  defp backward(4), do: 3
end

OxygenSystem.main()
