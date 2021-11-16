defmodule AdventOfCode2019.SetAndForget do
  @moduledoc """
  Day 17 — https://adventofcode.com/2019/day/17
  """

  require AdventOfCode2019.IntcodeComputer

  @spec part1(Enumerable.t()) :: integer
  def part1(in_stream) do
    in_stream
    |> load_program()
    |> gen_scaffold()
    |> sum_align_params()
  end

  @spec part2(Enumerable.t()) :: integer
  def part2(in_stream) do
    program = load_program(in_stream)

    gen_scaffold(program)
    |> find_path(program)
    |> compress_path()
    |> walk_path()
  end

  @spec load_program(Enumerable.t()) :: map
  defp load_program(in_stream) do
    in_stream
    |> Stream.map(&AdventOfCode2019.IntcodeComputer.load_program/1)
    |> Enum.take(1)
    |> List.first()
  end

  @type position :: {integer, integer}
  @type scaffold_data :: {map, position}
  @spec gen_scaffold(map) :: map
  defp gen_scaffold(program), do: gen_scaffold({:noop, {program, 0, 0}, nil}, {%{}, {0, 0}})

  @spec gen_scaffold({atom, tuple, integer | nil}, scaffold_data) :: map
  defp gen_scaffold({:done, _state, _type}, {scaff, _pos}), do: scaff

  defp gen_scaffold({result, state, type}, scaff_data) do
    AdventOfCode2019.IntcodeComputer.step(state)
    |> gen_scaffold(map_scaff(result, type, scaff_data))
  end

  @spec map_scaff(:output | :noop, char | nil, scaffold_data) :: scaffold_data
  defp map_scaff(:output, ?., {scaff, {x, y}}), do: {scaff, {x + 1, y}}
  defp map_scaff(:output, ?\n, {scaff, {_x, y}}), do: {scaff, {0, y + 1}}
  defp map_scaff(:output, type, {scaff, {x, y}}), do: {Map.put(scaff, {x, y}, type), {x + 1, y}}
  defp map_scaff(:noop, nil, scaff_data), do: scaff_data

  @spec sum_align_params(map) :: integer
  defp sum_align_params(scaff) do
    Stream.filter(scaff, fn {pos, _} -> is_align_param(pos, scaff) end)
    |> Enum.reduce(0, fn {{x, y}, _}, acc -> x * y + acc end)
  end

  @spec is_align_param(position, map) :: boolean
  defp is_align_param({x, y}, scaff) do
    Map.has_key?(scaff, {x + 1, y}) and Map.has_key?(scaff, {x, y - 1}) and
      Map.has_key?(scaff, {x, y + 1}) and Map.has_key?(scaff, {x - 1, y})
  end

  @spec find_path(map, map) :: {map, list}
  defp find_path(scaff, program) do
    {pos, heading} =
      Stream.filter(scaff, fn {_pos, type} -> type != ?# end)
      |> Enum.at(0)

    {program,
     find_path(scaff, pos, heading, get_delta(heading), [])
     |> Enum.map(&to_string/1)}
  end

  @type heading :: ?^ | ?v | ?< | ?> | :stop
  @type delta :: {-1 | 0 | 1, -1 | 0 | 1}
  @spec find_path(map, position, heading, delta, list) :: list
  defp find_path(_scaff, _pos, :stop, _delta, units), do: units

  defp find_path(scaff, {x, y}, heading, {dx, dy}, units)
       when not is_map_key(scaff, {x + dx, y + dy}) do
    {turn, heading} = turn(scaff, {x, y}, heading)
    units ++ turn ++ find_path(scaff, {x, y}, heading, get_delta(heading), [])
  end

  defp find_path(scaff, {x, y}, heading, {dx, dy}, []),
    do: find_path(scaff, {x + dx, y + dy}, heading, {dx, dy}, [1])

  defp find_path(scaff, {x, y}, heading, {dx, dy}, [units]),
    do: find_path(scaff, {x + dx, y + dy}, heading, {dx, dy}, [units + 1])

  @spec get_delta(heading) :: delta
  defp get_delta(?^), do: {0, -1}
  defp get_delta(?v), do: {0, 1}
  defp get_delta(?<), do: {-1, 0}
  defp get_delta(?>), do: {1, 0}
  defp get_delta(:stop), do: {0, 0}

  @spec turn(map, position, heading) :: {list, heading}
  defp turn(scaff, {x, y}, ?^) when is_map_key(scaff, {x - 1, y}), do: {["L"], ?<}
  defp turn(scaff, {x, y}, ?^) when is_map_key(scaff, {x + 1, y}), do: {["R"], ?>}
  defp turn(scaff, {x, y}, ?v) when is_map_key(scaff, {x + 1, y}), do: {["L"], ?>}
  defp turn(scaff, {x, y}, ?v) when is_map_key(scaff, {x - 1, y}), do: {["R"], ?<}
  defp turn(scaff, {x, y}, ?<) when is_map_key(scaff, {x, y + 1}), do: {["L"], ?v}
  defp turn(scaff, {x, y}, ?<) when is_map_key(scaff, {x, y - 1}), do: {["R"], ?^}
  defp turn(scaff, {x, y}, ?>) when is_map_key(scaff, {x, y - 1}), do: {["L"], ?^}
  defp turn(scaff, {x, y}, ?>) when is_map_key(scaff, {x, y + 1}), do: {["R"], ?v}
  defp turn(_scaff, _pos, _heading), do: {[], :stop}

  @spec compress_path({map, list}) :: {map, tuple}
  defp compress_path({program, path}),
    do: {program, BruteForceCompressor.compress(Enum.join(path, ","))}

  @spec walk_path({map, tuple}) :: integer
  defp walk_path({program, {main, funcs}}),
    do: walk_path({Map.put(program, 0, 2), [main | Map.values(funcs)] ++ ["n"]})

  @spec walk_path({map, list}) :: integer
  defp walk_path({program, movement_logic}) do
    input =
      Enum.join(movement_logic, "\n")
      |> Kernel.<>("\n")
      |> to_charlist()

    {:noop, {program, 0, 0}, nil}
    |> walk_path(input)
  end

  @spec walk_path({atom, tuple, integer | nil}, list) :: integer
  defp walk_path({:output, _state, output}, _in_out) when output > 255, do: output

  defp walk_path({:input, state, input}, _in_out) do
    AdventOfCode2019.IntcodeComputer.step(state, input)
    |> walk_path(input)
  end

  defp walk_path({_result, state, _in_out}, in_out) do
    AdventOfCode2019.IntcodeComputer.step(state, in_out)
    |> walk_path(in_out)
  end
end

defmodule BruteForceCompressor do
  @moduledoc """
  Day 17 — Brute Force Compressor — https://adventofcode.com/2019/day/17
  """

  @spec compress(String.t()) :: {String.t(), map}
  def compress(path), do: compress(path <> ",", sizes_list())

  @spec sizes_list() :: list
  defp sizes_list, do: for(x <- 5..1, y <- 5..1, z <- 5..1, do: [x, y, z])

  @spec compress(String.t(), list) :: {String.t(), map}
  defp compress(path, [sizes | tail]) do
    {result_data, f_bodies} = compress(path, sizes, ["A", "B", "C"], %{})

    if String.contains?(result_data, "L") or String.contains?(result_data, "R") do
      compress(path, tail)
    else
      {result_data, f_bodies}
    end
  end

  @spec compress(String.t(), list, list, map) :: {String.t(), map}
  defp compress(path, [], _f_names, f_bodies), do: {String.trim_trailing(path, ","), f_bodies}

  defp compress(path, [size | _] = sizes, f_names, f_bodies) do
    {:ok, regex} = Regex.compile("([RL],[0-9]+,){#{size}}")

    Regex.scan(regex, path, capture: :first)
    |> compress(path, sizes, f_names, f_bodies)
  end

  @spec compress(list, String.t(), list, list, map) :: {String.t(), map}
  defp compress([], path, [_size | sizes], f_names, f_bodies),
    do: compress(path, sizes, f_names, f_bodies)

  defp compress([[match] | _], path, [_size | sizes], [f_name | f_names], f_bodies) do
    f_body = String.trim_trailing(match, ",")

    String.replace(path, f_body, f_name)
    |> compress(sizes, f_names, Map.put(f_bodies, f_name, f_body))
  end
end
