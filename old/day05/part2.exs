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
        compute(Map.put(program, program[ptr + 1], 5), ptr + 2)

      [_, c, _, "4"] ->
        param(program, ptr + 1, c)
        |> IO.puts()

        compute(program, ptr + 2)

      [b, c, _, e] ->
        {param(program, ptr + 1, c), param(program, ptr + 2, b)}
        |> jump_less_equal(e, program, ptr)
    end
  end

  defp param(program, ptr, "0"), do: program[program[ptr]]
  defp param(program, ptr, _), do: program[ptr]

  defp jump_less_equal({p1, p2}, e, program, _)
       when (e == "5" and p1 != 0) or (e == "6" and p1 == 0),
       do: compute(program, p2)

  defp jump_less_equal(_, e, program, ptr)
       when e == "5" or e == "6",
       do: compute(program, ptr + 3)

  defp jump_less_equal({p1, p2}, e, program, ptr)
       when (e == "7" and p1 < p2) or (e == "8" and p1 == p2),
       do: compute(Map.put(program, program[ptr + 3], 1), ptr + 4)

  defp jump_less_equal(_, _, program, ptr) do
    compute(Map.put(program, program[ptr + 3], 0), ptr + 4)
  end
end

SunnyWithAsteroids.main()
