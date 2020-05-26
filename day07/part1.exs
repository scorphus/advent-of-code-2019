defmodule AmplificationCircuit do
  def main do
    program =
      IO.gets("")
      |> String.trim()
      |> String.split(",")
      |> Enum.with_index()
      |> Enum.map(fn {a, b} -> {b, String.to_integer(a)} end)
      |> Map.new()

    for(i <- 0..4, do: i)
    |> permute()
    |> amplify(program, 0)
    |> IO.puts()
  end

  def permute([]), do: [[]]

  def permute(list) do
    for x <- list, y <- permute(list -- [x]), do: [x | y]
  end

  defp amplify([], _, max_output), do: max_output

  defp amplify([phase_setting | tail], program, max_output) do
    output =
      phase_setting
      |> compute(program, 0)

    amplify(tail, program, Enum.max([max_output, output]))
  end

  defp compute([], _, input), do: input

  defp compute([phase | tail], program, input) do
    output = compute(program, 0, [phase, input], nil)
    compute(tail, program, output)
  end

  defp compute(program, ptr, input, output) do
    program[ptr]
    |> Integer.to_string()
    |> String.pad_leading(4, "0")
    |> String.codepoints()
    |> case do
      [_, _, _, "9"] ->
        output

      [b, c, _, "1"] ->
        result = param(program, ptr + 1, c) + param(program, ptr + 2, b)
        compute(Map.put(program, program[ptr + 3], result), ptr + 4, input, output)

      [b, c, _, "2"] ->
        result = param(program, ptr + 1, c) * param(program, ptr + 2, b)
        compute(Map.put(program, program[ptr + 3], result), ptr + 4, input, output)

      [_, _, _, "3"] ->
        [i_head | input] = input
        compute(Map.put(program, program[ptr + 1], i_head), ptr + 2, input, output)

      [_, c, _, "4"] ->
        compute(program, ptr + 2, input, param(program, ptr + 1, c))

      [b, c, _, e] ->
        {param(program, ptr + 1, c), param(program, ptr + 2, b)}
        |> jump_less_equal(e, program, ptr, input, output)
    end
  end

  defp param(program, ptr, "0"), do: program[program[ptr]]
  defp param(program, ptr, _), do: program[ptr]

  defp jump_less_equal({p1, p2}, e, program, _, input, output)
       when (e == "5" and p1 != 0) or (e == "6" and p1 == 0),
       do: compute(program, p2, input, output)

  defp jump_less_equal(_, e, program, ptr, input, output)
       when e == "5" or e == "6",
       do: compute(program, ptr + 3, input, output)

  defp jump_less_equal({p1, p2}, e, program, ptr, input, output)
       when (e == "7" and p1 < p2) or (e == "8" and p1 == p2),
       do: compute(Map.put(program, program[ptr + 3], 1), ptr + 4, input, output)

  defp jump_less_equal(_, _, program, ptr, input, output) do
    compute(Map.put(program, program[ptr + 3], 0), ptr + 4, input, output)
  end
end

AmplificationCircuit.main()
