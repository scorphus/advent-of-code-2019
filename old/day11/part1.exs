defmodule SpacePolice do
  def main do
    IO.gets("")
    |> String.trim()
    |> String.split(",")
    |> Stream.with_index()
    |> Stream.map(fn {a, b} -> {b, String.to_integer(a)} end)
    |> Map.new()
    |> PaintingRobot.paint(0)
    |> map_size()
    |> IO.inspect(label: "Number of panels painted at least once")
  end
end

SpacePolice.main()
