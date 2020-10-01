defmodule AdventOfCode2019Test do
  use ExUnit.Case

  import Mock

  doctest AdventOfCode2019
  doctest RocketEquation
  doctest TwelveOhTwoProgramAlarm
  doctest CrossedWires
  doctest SecureContainer

  @parameters [
    {"1.1", ["12", "14", "1969", "100756"], 34_241},
    {"1.2", ["12", "14", "1969", "100756"], 51_316}
  ]

  for {day_part, input, expected} <- @parameters do
    test "AdventOfCode2019.stream_lines##{day_part} == #{expected}" do
      assert AdventOfCode2019.stream_lines(unquote(input), unquote(day_part)) == unquote(expected)
    end
  end

  @days [
    RocketEquation,
    TwelveOhTwoProgramAlarm,
    CrossedWires,
    SecureContainer
  ]

  for {day_to_mock, i} <- Enum.with_index(@days) do
    test "AdventOfCode2019.stream_lines_mock##{i}" do
      with_mock unquote(day_to_mock),
        part1: fn _in_stream -> 1 end,
        part2: fn _in_stream -> 2 end do
        assert AdventOfCode2019.stream_lines([], "#{unquote(i) + 1}.1") == 1
        assert AdventOfCode2019.stream_lines([], "#{unquote(i) + 1}.2") == 2
      end
    end
  end
end
