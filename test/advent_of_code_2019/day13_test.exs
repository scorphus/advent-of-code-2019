defmodule AdventOfCode2019.CarePackageTest do
  use ExUnit.Case

  test "AdventOfCode2019.CarePackage.part1" do
    data = File.stream!("data/day13")
    assert AdventOfCode2019.CarePackage.part1(data) == 335
  end

  test "AdventOfCode2019.CarePackage.part2" do
    data = File.stream!("data/day13")
    assert AdventOfCode2019.CarePackage.part2(data) == 15_706
  end
end
