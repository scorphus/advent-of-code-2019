defmodule SensorBoost do
  def main do
    IO.gets("")
    |> String.trim()
    |> String.split(",")
    |> Stream.with_index()
    |> Stream.map(fn {a, b} -> {b, String.to_integer(a)} end)
    |> Map.new()
    |> compute(0, 0)
  end

  defp compute(program, ptr, rel_base) do
    program[ptr]
    |> Integer.to_string()
    |> String.pad_leading(5, "0")
    |> String.codepoints()
    |> compute(program, ptr, rel_base)
  end

  defp compute(["0", "0", "0", "9", "9"], program, _ptr, _rel_base), do: program

  defp compute([a, b, c, "0", "1"], program, ptr, rel_base) do
    (read(program, ptr + 1, c, rel_base) + read(program, ptr + 2, b, rel_base))
    |> write(program, ptr + 3, a, rel_base)
    |> compute(ptr + 4, rel_base)
  end

  defp compute([a, b, c, "0", "2"], program, ptr, rel_base) do
    (read(program, ptr + 1, c, rel_base) * read(program, ptr + 2, b, rel_base))
    |> write(program, ptr + 3, a, rel_base)
    |> compute(ptr + 4, rel_base)
  end

  defp compute(["0", "0", c, "0", "3"], program, ptr, rel_base) do
    System.argv()
    |> List.first()
    |> String.to_integer()
    |> write(program, ptr + 1, c, rel_base)
    |> compute(ptr + 2, rel_base)
  end

  defp compute(["0", "0", c, "0", "4"], program, ptr, rel_base) do
    IO.puts(read(program, ptr + 1, c, rel_base))
    compute(program, ptr + 2, rel_base)
  end

  defp compute(["0", "0", c, "0", "9"], program, ptr, rel_base) do
    compute(program, ptr + 2, rel_base + read(program, ptr + 1, c, rel_base))
  end

  defp compute([a, b, c, "0", e], program, ptr, rel_base)
       when e == "5" or e == "6" or e == "7" or e == "8" do
    {read(program, ptr + 1, c, rel_base), read(program, ptr + 2, b, rel_base)}
    |> jump_less_equal(a, e, program, ptr, rel_base)
  end

  defp read(program, ptr, "0", _rel_base), do: Map.get(program, Map.get(program, ptr, 0), 0)
  defp read(program, ptr, "1", _rel_base), do: Map.get(program, ptr, 0)

  defp read(program, ptr, "2", rel_base),
    do: Map.get(program, rel_base + Map.get(program, ptr, 0), 0)

  defp write(result, program, ptr, "2", rel_base) do
    Map.put(program, rel_base + Map.get(program, ptr, 0), result)
  end

  defp write(result, program, ptr, "0", _rel_base) do
    Map.put(program, Map.get(program, ptr, 0), result)
  end

  defp jump_less_equal({p1, p2}, _a, e, program, _ptr, rel_base)
       when (e == "5" and p1 != 0) or (e == "6" and p1 == 0),
       do: compute(program, p2, rel_base)

  defp jump_less_equal(_params, _a, e, program, ptr, rel_base)
       when e == "5" or e == "6",
       do: compute(program, ptr + 3, rel_base)

  defp jump_less_equal({p1, p2}, a, e, program, ptr, rel_base)
       when (e == "7" and p1 < p2) or (e == "8" and p1 == p2) do
    write(1, program, ptr + 3, a, rel_base)
    |> compute(ptr + 4, rel_base)
  end

  defp jump_less_equal(_params, a, _e, program, ptr, rel_base) do
    write(0, program, ptr + 3, a, rel_base)
    |> compute(ptr + 4, rel_base)
  end
end

SensorBoost.main()
