defmodule SetAndForget do
  def main do
    read_ascii()
    |> gen_scaffold()
    |> sum_align_params()
    |> IO.inspect(label: "Sum of the alignment parameters")
  end

  def read_ascii do
    IO.gets("")
    |> String.trim()
    |> String.split(",")
    |> Stream.with_index()
    |> Stream.map(fn {a, b} -> {b, String.to_integer(a)} end)
    |> Map.new()
  end

  defp gen_scaffold(program),
    do: gen_scaffold({:noop, {program, 0, 0}, nil}, {%{}, {0, 0}})

  defp gen_scaffold({:done, _state, _output}, {scaff, _pos}), do: scaff

  defp gen_scaffold({result, state, output}, scaff_data) do
    Computer.compute(state)
    |> gen_scaffold(map_scaff(result, output, scaff_data))
  end

  defp map_scaff(:output, ?., {scaff, {x, y}}), do: {scaff, {x + 1, y}}

  defp map_scaff(:output, ?\n, {scaff, {_x, y}}), do: {scaff, {0, y + 1}}

  defp map_scaff(:output, _output, {scaff, {x, y}}) do
    {Map.put(scaff, {x, y}, 1), {x + 1, y}}
  end

  defp map_scaff(:noop, nil, scaff_data), do: scaff_data

  defp sum_align_params(scaff) do
    Stream.filter(scaff, fn {pos, _} -> is_align_param(pos, scaff) == 4 end)
    |> Enum.reduce(0, fn {{x, y}, _}, acc -> x * y + acc end)
  end

  defp is_align_param({x, y}, scaff) do
    Map.get(scaff, {x, y + 1}, 0) +
      Map.get(scaff, {x + 1, y}, 0) +
      Map.get(scaff, {x, y - 1}, 0) +
      Map.get(scaff, {x - 1, y}, 0)
  end
end

SetAndForget.main()
