defmodule AdventOfCode2019.Amplifier do
  @moduledoc """
  Day 7 — https://adventofcode.com/2019/day/7
  """

  use GenServer

  @impl true
  def init(program), do: {:ok, {program, program, 0, []}}

  @impl true
  def handle_call({:reset, phase}, _from, {orig_program, _, _, _}) do
    {:reply, :ok, {orig_program, orig_program, 0, [phase]}}
  end

  @impl true
  def handle_call({:amplify, input}, _from, {orig_program, program, ptr, phase}) do
    {result, {program, ptr, _}, output} = amplify({nil, {program, ptr, 0}, nil}, phase ++ [input])
    {:reply, {result, output}, {orig_program, program, ptr, []}}
  end

  defp amplify({result, state, output}, _) when result == :output or result == :done do
    {result, state, output}
  end

  defp amplify({:input, state, input}, _) do
    AdventOfCode2019.IntcodeComputer.step(state, input)
    |> amplify(input)
  end

  defp amplify({_result, state, _output}, input) do
    AdventOfCode2019.IntcodeComputer.step(state, input)
    |> amplify(input)
  end
end
