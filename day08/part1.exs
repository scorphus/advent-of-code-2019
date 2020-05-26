defmodule SpaceImageFormat do
  def main do
    IO.gets("")
    |> String.trim()
    |> String.graphemes()
    |> Stream.chunk_every(25 * 6)
    |> Stream.map(fn l ->
      [Enum.count(l, &(&1 == "0")), Enum.count(l, &(&1 == "1")) * Enum.count(l, &(&1 == "2"))]
    end)
    |> Enum.min_by(fn [a, _] -> a end)
    |> IO.inspect()
  end
end

SpaceImageFormat.main()
