defmodule AdventOfCode2019.SetAndForgetTest do
  use ExUnit.Case

  test "AdventOfCode2019.SetAndForget.part1" do
    data = File.stream!("data/day17")
    assert AdventOfCode2019.SetAndForget.part1(data) == 2660
  end

  test "AdventOfCode2019.SetAndForget.part2" do
    data = File.stream!("data/day17")
    assert AdventOfCode2019.SetAndForget.part2(data) == 790_595
  end
end
