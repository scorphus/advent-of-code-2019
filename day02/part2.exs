defmodule TwelveOhTwoProgramAlarm do
  def main do
    IO.gets("")
    |> String.trim()
    |> String.split(",")
    |> Enum.with_index()
    |> Enum.map(fn {a, b} -> {b, String.to_integer(a)} end)
    |> Map.new()
    |> find_pair(19_690_720, 0, 0)
    |> IO.inspect(label: "pair of inputs")
  end

  defp find_pair(program, wanted_output, 127, verb) do
    cond do
      compute(program, 127, verb) == wanted_output ->
        100 * 127 + verb

      true ->
        find_pair(program, wanted_output, 0, verb + 1)
    end
  end

  defp find_pair(program, wanted_output, noun, verb) do
    cond do
      compute(program, noun, verb) == wanted_output ->
        100 * noun + verb

      true ->
        find_pair(program, wanted_output, noun + 1, verb)
    end
  end

  defp compute(program, noun, verb) do
    Map.put(program, 1, noun)
    |> Map.put(2, verb)
    |> compute(0)
  end

  defp compute(program, opcode_idx) do
    case program[opcode_idx] do
      1 ->
        result = program[program[opcode_idx + 1]] + program[program[opcode_idx + 2]]
        compute(Map.put(program, program[opcode_idx + 3], result), opcode_idx + 4)

      2 ->
        result = program[program[opcode_idx + 1]] * program[program[opcode_idx + 2]]
        compute(Map.put(program, program[opcode_idx + 3], result), opcode_idx + 4)

      99 ->
        program[0]
    end
  end
end

TwelveOhTwoProgramAlarm.main()
