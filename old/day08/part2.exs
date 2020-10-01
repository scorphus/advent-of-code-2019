defmodule SpaceImageFormat do
  def main do
    IO.gets("")
    |> String.trim()
    |> String.graphemes()
    |> Stream.chunk_every(25 * 6)
    |> Enum.reduce(&merge_layers/2)
    |> Stream.chunk_every(25)
    |> Enum.map_join("\n", &join_row/1)
    |> IO.puts()
  end

  defp merge_layers(back, fore) do
    Enum.zip(back, fore)
    |> Enum.map(&merge_pixels/1)
  end

  defp merge_pixels({back, "2"}), do: back
  defp merge_pixels({_, fore}), do: fore

  defp join_row(row), do: Enum.map_join(row, &paint_pixels/1)

  defp paint_pixels("0"), do: "░░"
  defp paint_pixels("1"), do: "▓▓"
  defp paint_pixels(_), do: "  "
end

SpaceImageFormat.main()
