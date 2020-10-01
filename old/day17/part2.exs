defmodule SetAndForget do
  def main do
    read_ascii()
    |> gen_scaffold()
    |> find_path()
    |> compress_path()
    |> walk_path()
    |> IO.inspect(label: "What a boring, worthless challenge 😞 The answer is")

    exit(:shutdown)
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
    do: {program, gen_scaffold({:noop, {program, 0, 0}, nil}, {%{}, {0, 0}})}

  defp gen_scaffold({:done, _state, _type}, {scaff, _pos}), do: scaff

  defp gen_scaffold({result, state, type}, scaff_data) do
    Computer.compute(state)
    |> gen_scaffold(map_scaff(result, type, scaff_data))
  end

  defp map_scaff(:output, ?., {scaff, {x, y}}), do: {scaff, {x + 1, y}}
  defp map_scaff(:output, ?\n, {scaff, {_x, y}}), do: {scaff, {0, y + 1}}
  defp map_scaff(:output, type, {scaff, {x, y}}), do: {Map.put(scaff, {x, y}, type), {x + 1, y}}
  defp map_scaff(:noop, nil, scaff_data), do: scaff_data

  defp find_path({program, scaff}) do
    {pos, heading} =
      Stream.filter(scaff, fn {_pos, type} -> type != ?# end)
      |> Enum.at(0)

    {program,
     find_path(scaff, pos, heading, get_delta(heading), [])
     |> Enum.map(&to_string/1)}
  end

  defp find_path(_scaff, _pos, :stop, _delta, units), do: units

  defp find_path(scaff, {x, y}, heading, {dx, dy}, units)
       when not is_map_key(scaff, {x + dx, y + dy}) do
    {turn, heading} = turn(scaff, {x, y}, heading)
    units ++ turn ++ find_path(scaff, {x, y}, heading, get_delta(heading), [])
  end

  defp find_path(scaff, {x, y}, heading, {dx, dy}, []) do
    find_path(scaff, {x + dx, y + dy}, heading, {dx, dy}, [1])
  end

  defp find_path(scaff, {x, y}, heading, {dx, dy}, [units]) do
    find_path(scaff, {x + dx, y + dy}, heading, {dx, dy}, [units + 1])
  end

  defp get_delta(?^), do: {0, -1}
  defp get_delta(?v), do: {0, 1}
  defp get_delta(?<), do: {-1, 0}
  defp get_delta(?>), do: {1, 0}
  defp get_delta(:stop), do: {0, 0}

  defp turn(scaff, {x, y}, ?^) when is_map_key(scaff, {x - 1, y}), do: {["L"], ?<}
  defp turn(scaff, {x, y}, ?^) when is_map_key(scaff, {x + 1, y}), do: {["R"], ?>}
  defp turn(scaff, {x, y}, ?v) when is_map_key(scaff, {x + 1, y}), do: {["L"], ?>}
  defp turn(scaff, {x, y}, ?v) when is_map_key(scaff, {x - 1, y}), do: {["R"], ?<}
  defp turn(scaff, {x, y}, ?<) when is_map_key(scaff, {x, y + 1}), do: {["L"], ?v}
  defp turn(scaff, {x, y}, ?<) when is_map_key(scaff, {x, y - 1}), do: {["R"], ?^}
  defp turn(scaff, {x, y}, ?>) when is_map_key(scaff, {x, y - 1}), do: {["L"], ?^}
  defp turn(scaff, {x, y}, ?>) when is_map_key(scaff, {x, y + 1}), do: {["R"], ?v}
  defp turn(_scaff, _pos, _heading), do: {[], :stop}

  defp compress_path({program, path}) do
    {program, BruteForceCompressor.compress(Enum.join(path, ","))}
  end

  defp walk_path({program, {main, funcs}}) do
    walk_path({Map.put(program, 0, 2), [main | Map.values(funcs)] ++ ["n"]})
  end

  defp walk_path({program, movement_logic}) do
    input =
      Enum.join(movement_logic, "\n")
      |> Kernel.<>("\n")
      |> to_charlist()

    {:noop, {program, 0, 0}, nil}
    |> walk_path(input)
  end

  defp walk_path({:output, _state, output}, _in_out) when output > 255, do: output

  defp walk_path({:input, state, input}, _in_out) do
    Computer.compute(state, input)
    |> walk_path(input)
  end

  defp walk_path({_result, state, _in_out}, in_out) do
    Computer.compute(state, in_out)
    |> walk_path(in_out)
  end
end

defmodule BruteForceCompressor do
  def compress(path), do: compress(path <> ",", sizes_list())

  defp sizes_list(), do: for(x <- 5..1, y <- 5..1, z <- 5..1, do: [x, y, z])

  defp compress(_data, []), do: exit("no donuts for you")

  defp compress(path, [sizes | tail]) do
    {result_data, f_bodies} = compress(path, sizes, ["A", "B", "C"], %{})

    cond do
      String.contains?(result_data, "L") or String.contains?(result_data, "R") ->
        compress(path, tail)

      true ->
        {result_data, f_bodies}
    end
  end

  defp compress(path, [], _f_names, f_bodies) do
    {String.trim_trailing(path, ","), f_bodies}
  end

  defp compress(path, [size | _] = sizes, f_names, f_bodies) do
    {:ok, regex} = Regex.compile("([RL],[0-9]+,){#{size}}")

    Regex.scan(regex, path, capture: :first)
    |> compress(path, sizes, f_names, f_bodies)
  end

  defp compress([], path, [_size | sizes], f_names, f_bodies) do
    compress(path, sizes, f_names, f_bodies)
  end

  defp compress([[match] | _], path, [_size | sizes], [f_name | f_names], f_bodies) do
    f_body = String.trim_trailing(match, ",")

    String.replace(path, f_body, f_name)
    |> compress(sizes, f_names, Map.put(f_bodies, f_name, f_body))
  end
end

SetAndForget.main()
