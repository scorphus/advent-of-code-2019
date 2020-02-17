defmodule SunnyWithAsteroids do
  def main do
    IO.gets("")
    |> String.trim()
    |> String.split(",")
    |> Enum.with_index()
    |> Enum.map(fn {a, b} -> {b, String.to_integer(a)} end)
    |> Map.new()
    |> compute(0)
  end

  defp compute(program, ptr) do
    program[ptr]
    |> Integer.to_string()
    |> String.pad_leading(4, "0")
    |> String.codepoints()
    |> case do
      [_, _, _, "9"] ->
        program

      [b, c, _, "1"] ->
        result = param(program, ptr + 1, c) + param(program, ptr + 2, b)
        compute(Map.put(program, program[ptr + 3], result), ptr + 4)

      [b, c, _, "2"] ->
        result = param(program, ptr + 1, c) * param(program, ptr + 2, b)
        compute(Map.put(program, program[ptr + 3], result), ptr + 4)

      [_, _, _, "3"] ->
        compute(Map.put(program, program[ptr + 1], 1), ptr + 2)

      [_, c, _, "4"] ->
        param(program, ptr + 1, c)
        |> IO.puts()

        compute(program, ptr + 2)
    end
  end

  defp param(program, idx, "0"), do: program[program[idx]]
  defp param(program, idx, _), do: program[idx]
end

SunnyWithAsteroids.main()
