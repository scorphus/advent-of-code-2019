defmodule FlawedFrequencyTransmission do
  @base_pattern [0, 1, 0, -1]

  def main do
    read_input_signal()
    |> repeat_phases(100)
    |> Stream.take(8)
    |> Enum.join()
    |> IO.inspect(label: "\rFirst eight digits in the final output list")
  end

  defp read_input_signal do
    IO.gets("")
    |> String.trim()
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
  end

  defp repeat_phases(input_signal, phases) do
    Enum.reduce(1..phases, input_signal, &run_phases/2)
  end

  defp run_phases(phase, input_signal) do
    IO.write("\rPhase #{phase}...")

    Stream.transform(1..length(input_signal), input_signal, &output_signal/2)
    |> Enum.to_list()
  end

  defp output_signal(i, input_signal) do
    {[
       Stream.zip(input_signal, repeat_pattern(i))
       |> Stream.map(fn {a, b} -> a * b end)
       |> Enum.sum()
       |> rem(10)
       |> abs()
     ], input_signal}
  end

  defp repeat_pattern(n) do
    Stream.unfold({1, n, @base_pattern}, fn
      {_, _, []} -> nil
      {n, n, [head | tail]} -> {head, {1, n, tail}}
      {i, n, [head | tail]} -> {head, {i + 1, n, [head | tail]}}
    end)
    |> Stream.cycle()
    |> Stream.drop(1)
  end
end

FlawedFrequencyTransmission.main()
