defmodule PaintingRobot do
  def paint(program, starting_panel) do
    paint(:noop, {program, 0, 0}, starting_panel, {0, 0}, :up, %{}, :farbe)
  end

  defp paint(:done, _state, _in_out, _pos, _dir, hull, _action), do: hull

  defp paint(:noop, state, in_out, pos, dir, hull, action) do
    {result, state, in_out} = Computer.compute(state, in_out)
    paint(result, state, in_out, pos, dir, hull, action)
  end

  defp paint(:agir, state, in_out, pos, dir, hull, :farbe) do
    hull = Map.put(hull, pos, in_out)
    {result, state, in_out} = Computer.compute(state, in_out)
    paint(result, state, in_out, pos, dir, hull, :gehen)
  end

  defp paint(:agir, state, in_out, pos, dir, hull, :gehen) do
    {pos, dir} = move(in_out, pos, dir)
    in_out = Map.get(hull, pos, 0)
    {result, state, in_out} = Computer.compute(state, in_out)
    paint(result, state, in_out, pos, dir, hull, :farbe)
  end

  defp move(0, {x, y}, :up), do: {{x - 1, y}, :left}
  defp move(0, {x, y}, :left), do: {{x, y - 1}, :down}
  defp move(0, {x, y}, :down), do: {{x + 1, y}, :right}
  defp move(0, {x, y}, :right), do: {{x, y + 1}, :up}
  defp move(1, {x, y}, :up), do: {{x + 1, y}, :right}
  defp move(1, {x, y}, :right), do: {{x, y - 1}, :down}
  defp move(1, {x, y}, :down), do: {{x - 1, y}, :left}
  defp move(1, {x, y}, :left), do: {{x, y + 1}, :up}
end

defmodule Computer do
  def compute({program, ptr, rel_base}, in_out) do
    program[ptr]
    |> Integer.to_string()
    |> String.pad_leading(5, "0")
    |> String.codepoints()
    |> compute(program, ptr, rel_base, in_out)
  end

  defp compute(["0", "0", "0", "9", "9"], program, ptr, rel_base, in_out) do
    {:done, {program, ptr, rel_base}, in_out}
  end

  defp compute([a, b, c, "0", "1"], program, ptr, rel_base, in_out) do
    program =
      (read(program, ptr + 1, c, rel_base) + read(program, ptr + 2, b, rel_base))
      |> write(program, ptr + 3, a, rel_base)

    {:noop, {program, ptr + 4, rel_base}, in_out}
  end

  defp compute([a, b, c, "0", "2"], program, ptr, rel_base, in_out) do
    program =
      (read(program, ptr + 1, c, rel_base) * read(program, ptr + 2, b, rel_base))
      |> write(program, ptr + 3, a, rel_base)

    {:noop, {program, ptr + 4, rel_base}, in_out}
  end

  defp compute(["0", "0", c, "0", "3"], program, ptr, rel_base, in_out) do
    program = write(in_out, program, ptr + 1, c, rel_base)
    {:noop, {program, ptr + 2, rel_base}, in_out}
  end

  defp compute(["0", "0", c, "0", "4"], program, ptr, rel_base, _in_out) do
    {:agir, {program, ptr + 2, rel_base}, read(program, ptr + 1, c, rel_base)}
  end

  defp compute(["0", "0", c, "0", "9"], program, ptr, rel_base, in_out) do
    {:noop, {program, ptr + 2, rel_base + read(program, ptr + 1, c, rel_base)}, in_out}
  end

  defp compute([a, b, c, "0", e], program, ptr, rel_base, in_out)
       when e == "5" or e == "6" or e == "7" or e == "8" do
    {program, ptr} =
      {read(program, ptr + 1, c, rel_base), read(program, ptr + 2, b, rel_base)}
      |> jump_less_equal(a, e, program, ptr, rel_base)

    {:noop, {program, ptr, rel_base}, in_out}
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

  defp jump_less_equal({p1, p2}, _a, e, program, _ptr, _rel_base)
       when (e == "5" and p1 != 0) or (e == "6" and p1 == 0),
       do: {program, p2}

  defp jump_less_equal(_params, _a, e, program, ptr, _rel_base)
       when e == "5" or e == "6",
       do: {program, ptr + 3}

  defp jump_less_equal({p1, p2}, a, e, program, ptr, rel_base)
       when (e == "7" and p1 < p2) or (e == "8" and p1 == p2) do
    {write(1, program, ptr + 3, a, rel_base), ptr + 4}
  end

  defp jump_less_equal(_params, a, _e, program, ptr, rel_base) do
    {write(0, program, ptr + 3, a, rel_base), ptr + 4}
  end
end
