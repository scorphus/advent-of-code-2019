defmodule AdventOfCode2019.IntcodeComputer do
  @moduledoc """
  The Intcode Computer is used in the following days
  - Day 2 — https://adventofcode.com/2019/day/2
  - Day 5 — https://adventofcode.com/2019/day/5
  - Day 7 — https://adventofcode.com/2019/day/7
  """

  @spec compute(map(), integer(), integer(), any | integer()) ::
          {map(), integer(), integer(), integer()}
  def compute(program, ptr, rel_base, input \\ []),
    do: compute({:start, {program, ptr, rel_base}, nil}, input)

  defp compute({:done, {program, ptr, rel_base}, _input}, output),
    do: {program, ptr, rel_base, output}

  defp compute({:output, state, output}, input) do
    step(state, input)
    |> compute(output)
  end

  defp compute({:input, state, input}, _output) do
    step(state, input)
    |> compute(input)
  end

  defp compute({_result, state, _output}, input) do
    step(state, input)
    |> compute(input)
  end

  @spec step({map(), integer(), integer()}, list()) :: tuple()
  def step({program, ptr, rel_base}, input \\ []) do
    program[ptr]
    |> Integer.to_string()
    |> String.pad_leading(5, "0")
    |> String.codepoints()
    |> step(program, ptr, rel_base, input)
  end

  @spec step(list(), map(), integer(), integer(), list()) :: tuple()
  defp step(["0", "0", "0", "9", "9"], program, ptr, rel_base, _input),
    do: {:done, {program, ptr, rel_base}, nil}

  defp step([a, b, c, "0", "1"], program, ptr, rel_base, _input) do
    program =
      (read(program, ptr + 1, c, rel_base) + read(program, ptr + 2, b, rel_base))
      |> write(program, ptr + 3, a, rel_base)

    {:noop, {program, ptr + 4, rel_base}, nil}
  end

  defp step([a, b, c, "0", "2"], program, ptr, rel_base, _input) do
    program =
      (read(program, ptr + 1, c, rel_base) * read(program, ptr + 2, b, rel_base))
      |> write(program, ptr + 3, a, rel_base)

    {:noop, {program, ptr + 4, rel_base}, nil}
  end

  defp step(["0", "0", c, "0", "3"], program, ptr, rel_base, [input | tail]) do
    program = write(input, program, ptr + 1, c, rel_base)
    {:input, {program, ptr + 2, rel_base}, tail}
  end

  defp step(["0", "0", c, "0", "4"], program, ptr, rel_base, _input) do
    {:output, {program, ptr + 2, rel_base}, read(program, ptr + 1, c, rel_base)}
  end

  defp step(["0", "0", c, "0", "9"], program, ptr, rel_base, _input) do
    {:noop, {program, ptr + 2, rel_base + read(program, ptr + 1, c, rel_base)}, nil}
  end

  defp step([a, b, c, "0", e], program, ptr, rel_base, _input)
       when e == "5" or e == "6" or e == "7" or e == "8" do
    {program, ptr} =
      {read(program, ptr + 1, c, rel_base), read(program, ptr + 2, b, rel_base)}
      |> jump_less_equal(a, e, program, ptr, rel_base)

    {:noop, {program, ptr, rel_base}, nil}
  end

  @spec read(map(), integer(), String.t(), integer()) :: integer()
  defp read(program, ptr, "0", _rel_base), do: Map.get(program, Map.get(program, ptr, 0), 0)
  defp read(program, ptr, "1", _rel_base), do: Map.get(program, ptr, 0)

  defp read(program, ptr, "2", rel_base),
    do: Map.get(program, rel_base + Map.get(program, ptr, 0), 0)

  @spec write(integer(), map(), integer, String.t(), integer()) :: map()
  defp write(result, program, ptr, "2", rel_base),
    do: Map.put(program, rel_base + Map.get(program, ptr, 0), result)

  defp write(result, program, ptr, "0", _rel_base),
    do: Map.put(program, Map.get(program, ptr, 0), result)

  @spec jump_less_equal(
          {integer(), integer()},
          String.t(),
          String.t(),
          map(),
          integer(),
          integer()
        ) :: {map(), integer()}
  defp jump_less_equal({p1, p2}, _a, e, program, _ptr, _rel_base)
       when (e == "5" and p1 != 0) or (e == "6" and p1 == 0),
       do: {program, p2}

  defp jump_less_equal(_params, _a, e, program, ptr, _rel_base)
       when e == "5" or e == "6",
       do: {program, ptr + 3}

  defp jump_less_equal({p1, p2}, a, e, program, ptr, rel_base)
       when (e == "7" and p1 < p2) or (e == "8" and p1 == p2),
       do: {write(1, program, ptr + 3, a, rel_base), ptr + 4}

  defp jump_less_equal(_params, a, _e, program, ptr, rel_base),
    do: {write(0, program, ptr + 3, a, rel_base), ptr + 4}
end
