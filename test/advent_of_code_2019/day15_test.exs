defmodule AdventOfCode2019.OxygenSystemTest do
  use ExUnit.Case

  test "AdventOfCode2019.OxygenSystem.part1" do
    data = File.stream!("data/day15")
    assert AdventOfCode2019.OxygenSystem.part1(data) == 212
  end

  test "AdventOfCode2019.OxygenSystem.part2" do
    data = File.stream!("data/day15")
    assert AdventOfCode2019.OxygenSystem.part2(data) == 358
  end
end
