defmodule AmplificationCircuit do
  def main do
    amplifiers =
      IO.gets("")
      |> String.trim()
      |> String.split(",")
      |> Enum.with_index()
      |> Enum.map(fn {a, b} -> {b, String.to_integer(a)} end)
      |> Map.new()
      |> start_amplifiers([], 5)

    for(i <- 5..9, do: i)
    |> permute()
    |> find_highest_signal(amplifiers, 0)
    |> IO.puts()
  end

  defp start_amplifiers(_, amplifiers, 0), do: Enum.reverse(amplifiers)

  defp start_amplifiers(program, amplifiers, n) do
    {:ok, amp} = GenServer.start(Amplifier, program)
    start_amplifiers(program, [amp | amplifiers], n - 1)
  end

  def permute([]), do: [[]]

  def permute(list) do
    for x <- list, y <- permute(list -- [x]), do: [x | y]
  end

  def find_highest_signal([], _, highest_signal), do: highest_signal

  def find_highest_signal([phase_setting | tail], amplifiers, highest_signal) do
    signal =
      reset_amplifiers(phase_setting, amplifiers, [])
      |> amplify([], 0, false)

    find_highest_signal(tail, amplifiers, Enum.max([highest_signal, signal]))
  end

  defp reset_amplifiers([], [], amplifiers), do: Enum.reverse(amplifiers)

  defp reset_amplifiers([phase | phase_tail], [amp | amp_tail], amplifiers) do
    :ok = GenServer.call(amp, {:reset, phase})
    reset_amplifiers(phase_tail, amp_tail, [amp | amplifiers])
  end

  defp amplify([], _, input, true), do: input

  defp amplify([], amplifiers, input, _) do
    amplify(Enum.reverse(amplifiers), [], input, false)
  end

  defp amplify([amp | tail], amplifiers, input, _) do
    {output, done} = GenServer.call(amp, {:amplify, input})
    amplify(tail, [amp | amplifiers], output, done)
  end
end

defmodule Amplifier do
  use GenServer

  @impl true
  def init(program), do: {:ok, {program, program, 0, [], 0}}

  @impl true
  def handle_call({:reset, phase}, _from, {orig_program, _, _, _, _}) do
    {:reply, :ok, {orig_program, orig_program, 0, [phase], 0}}
  end

  @impl true
  def handle_call({:amplify, input}, _from, {orig_program, program, ptr, phase, output}) do
    {program, ptr, output, done} = Computer.compute(program, ptr, phase ++ [input], output)
    {:reply, {output, done}, {orig_program, program, ptr, [], output}}
  end
end

defmodule Computer do
  def compute(program, ptr, input, output) do
    program[ptr]
    |> Integer.to_string()
    |> String.pad_leading(4, "0")
    |> String.codepoints()
    |> case do
      [_, _, _, "9"] ->
        {program, ptr, output, true}

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
        {program, ptr + 2, param(program, ptr + 1, c), false}

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
