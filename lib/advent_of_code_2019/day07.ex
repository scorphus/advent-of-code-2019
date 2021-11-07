defmodule AdventOfCode2019.AmplificationCircuit do
  @moduledoc """
  Day 7 — https://adventofcode.com/2019/day/7
  """

  require AdventOfCode2019.IntcodeComputer

  @doc """
  iex> ["3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0"]
  iex> |> AdventOfCode2019.AmplificationCircuit.part1()
  43210
  iex> ["3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0"]
  iex> |> AdventOfCode2019.AmplificationCircuit.part1()
  54321
  iex> ["3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0"]
  iex> |> AdventOfCode2019.AmplificationCircuit.part1()
  65210
  """
  @spec part1(Enumerable.t()) :: integer()
  def part1(in_stream) do
    program =
      in_stream
      |> Stream.map(&AdventOfCode2019.IntcodeComputer.load_program/1)
      |> Enum.take(1)
      |> List.first()

    for(i <- 0..4, do: i)
    |> permute()
    |> amplify(program, 0)
  end

  @doc """
  iex> ["3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0"]
  iex> |> AdventOfCode2019.AmplificationCircuit.part1()
  43210
  iex> ["3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0"]
  iex> |> AdventOfCode2019.AmplificationCircuit.part1()
  54321
  iex> ["3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0"]
  iex> |> AdventOfCode2019.AmplificationCircuit.part1()
  65210
  """
  @spec part2(Enumerable.t()) :: integer()
  def part2(in_stream) do
    amplifiers =
      in_stream
      |> Stream.map(&AdventOfCode2019.IntcodeComputer.load_program/1)
      |> Enum.take(1)
      |> List.first()
      |> start_amplifiers(5)

    for(i <- 5..9, do: i)
    |> permute()
    |> find_highest_signal(amplifiers, 0)
  end

  @spec permute(Enumerable.t()) :: Enumerable.t()
  def permute([]), do: [[]]

  def permute(list) do
    for x <- list, y <- permute(list -- [x]), do: [x | y]
  end

  @spec amplify(Enumerable.t(), map(), integer()) :: integer()
  defp amplify([], _program, max_output), do: max_output

  defp amplify([phase_setting | tail], program, max_output) do
    output =
      phase_setting
      |> compute(program, 0)

    amplify(tail, program, Enum.max([max_output, output]))
  end

  @spec compute(Enumerable.t(), map(), integer()) :: integer()
  defp compute([], _program, input), do: input

  defp compute([phase | tail], program, input) do
    {_, _, _, output} = AdventOfCode2019.IntcodeComputer.compute(program, 0, 0, [phase, input])
    compute(tail, program, output)
  end

  @spec start_amplifiers(map(), integer(), Enumerable.t()) :: Enumerable.t()
  defp start_amplifiers(program, n, amplifiers \\ [])

  defp start_amplifiers(_program, 0, amplifiers), do: Enum.reverse(amplifiers)

  defp start_amplifiers(program, n, amplifiers) do
    {:ok, amp} = GenServer.start(AdventOfCode2019.Amplifier, program)
    start_amplifiers(program, n - 1, [amp | amplifiers])
  end

  @spec find_highest_signal(Enumerable.t(), Enumerable.t(), integer()) :: integer()
  def find_highest_signal([], _amplifiers, highest_signal), do: highest_signal

  def find_highest_signal([phase_setting | tail], amplifiers, highest_signal) do
    signal =
      reset_amplifiers(phase_setting, amplifiers, [])
      |> amplify_serial([], 0)

    find_highest_signal(tail, amplifiers, Enum.max([highest_signal, signal]))
  end

  @spec reset_amplifiers(Enumerable.t(), Enumerable.t(), Enumerable.t()) :: Enumerable.t()
  defp reset_amplifiers([], [], amplifiers), do: Enum.reverse(amplifiers)

  defp reset_amplifiers([phase | phase_tail], [amp | amp_tail], amplifiers) do
    :ok = GenServer.call(amp, {:reset, phase})
    reset_amplifiers(phase_tail, amp_tail, [amp | amplifiers])
  end

  @spec amplify_serial(Enumerable.t(), Enumerable.t(), integer()) :: integer()
  defp amplify_serial([], amplifiers, input) do
    amplify_serial(Enum.reverse(amplifiers), [], input)
  end

  defp amplify_serial([amp | tail], amplifiers, input) do
    case GenServer.call(amp, {:amplify, input}) do
      {:done, _} -> input
      {:output, output} -> amplify_serial(tail, [amp | amplifiers], output)
    end
  end
end
