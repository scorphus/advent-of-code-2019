defmodule AdventOfCode2019.SpacePoliceTest do
  use ExUnit.Case

  test "AdventOfCode2019.SpacePolice.part1" do
    data = File.stream!("data/day11")
    assert AdventOfCode2019.SpacePolice.part1(data) == 1951
  end

  test "AdventOfCode2019.SpacePolice.part2" do
    data = File.stream!("data/day11")

    expected =
      """
      ░░▓▓░░░░▓▓░░▓▓░░░░▓▓░░░░░░▓▓▓▓░░▓▓▓▓▓▓░░░░░░▓▓▓▓░░░░▓▓░░░░▓▓░░░░▓▓▓▓░░░░▓▓▓▓▓▓░░░░░░░░
      ░░▓▓░░░░▓▓░░▓▓░░▓▓░░░░░░░░░░▓▓░░▓▓░░░░▓▓░░▓▓░░░░▓▓░░▓▓░░░░▓▓░░▓▓░░░░▓▓░░▓▓░░░░▓▓░░░░░░
      ░░▓▓▓▓▓▓▓▓░░▓▓▓▓░░░░░░░░░░░░▓▓░░▓▓▓▓▓▓░░░░▓▓░░░░▓▓░░▓▓▓▓▓▓▓▓░░▓▓░░░░░░░░▓▓░░░░▓▓░░░░░░
      ░░▓▓░░░░▓▓░░▓▓░░▓▓░░░░░░░░░░▓▓░░▓▓░░░░▓▓░░▓▓▓▓▓▓▓▓░░▓▓░░░░▓▓░░▓▓░░░░░░░░▓▓▓▓▓▓░░░░░░░░
      ░░▓▓░░░░▓▓░░▓▓░░▓▓░░░░▓▓░░░░▓▓░░▓▓░░░░▓▓░░▓▓░░░░▓▓░░▓▓░░░░▓▓░░▓▓░░░░▓▓░░▓▓░░▓▓░░░░░░░░
      ░░▓▓░░░░▓▓░░▓▓░░░░▓▓░░░░▓▓▓▓░░░░▓▓▓▓▓▓░░░░▓▓░░░░▓▓░░▓▓░░░░▓▓░░░░▓▓▓▓░░░░▓▓░░░░▓▓░░░░░░
      """
      |> String.trim_trailing()

    assert AdventOfCode2019.SpacePolice.part2(data) == expected
  end
end
