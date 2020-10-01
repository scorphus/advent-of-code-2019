defmodule AdventOfCode2019.CLI do
  @moduledoc """
  Collect command line arguments and input, run the specified day and part,
  and return the answer

  ./advent_of_code-2019 <day>.<part> < <input>
  """

  @spec main(Enumerable.t()) :: any()
  def main([]) do
    IO.puts("Missing day.part! Ex.: ./advent_of_code_2019 < day01/input 1.1")
    System.halt(1)
  end

  def main(args) do
    IO.stream(:stdio, :line)
    |> AdventOfCode2019.stream_lines(Enum.join(args, "."))
    # credo:disable-for-next-line
    |> IO.inspect(label: "Your answer is")
  end
end
