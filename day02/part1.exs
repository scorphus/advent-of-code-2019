defmodule TwelveOhTwoProgramAlarm do
  def main do
    IO.gets("")
    |> String.trim()
    |> String.split(",")
    |> Enum.with_index()
    |> Enum.map(fn {a, b} -> {b, String.to_integer(a)} end)
    |> Map.new()
    |> Map.put(1, 12)
    |> Map.put(2, 2)
    |> compute(0)
    |> IO.inspect(label: "value at position 0")
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
