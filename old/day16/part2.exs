defmodule FlawedFrequencyTransmission do
  def main do
    input_signal = read_input_signal()

    offset =
      Enum.slice(input_signal, 0, 7)
      |> Enum.join()
      |> String.to_integer()

    size = 10_000 * length(input_signal)

    unless offset / size > 1 / 2 do
      exit("Offset is not large enough")
    end

    repeat_phases(input_signal, 100, size, offset)
    |> Stream.take(8)
    |> Enum.join()
    |> IO.inspect(label: "First eight digits in the final output list")
  end

  defp read_input_signal do
    IO.gets("")
    |> String.trim()
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
  end

  defp repeat_phases(input_signal, phases, size, offset) do
    Stream.cycle(input_signal)
    |> Stream.drop(offset)
    |> Enum.take(size - offset)
    |> Stream.iterate(&run_phases/1)
    |> Enum.at(phases)
  end

  defp run_phases(input_signal) do
    {input_signal, _} = output_signal(input_signal)
    input_signal
  end

  defp output_signal([n]), do: {[n], n}

  defp output_signal([n | tail]) do
    {tail, sum} = output_signal(tail)
    {[rem(n + sum, 10) | tail], n + sum}
  end
end

FlawedFrequencyTransmission.main()
