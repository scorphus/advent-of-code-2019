defmodule AdventOfCode2019.TheNBodyProblemTest do
  use ExUnit.Case

  @parameters [
    {[
       "<x=-1, y=0, z=2>",
       "<x=2, y=-10, z=-7>",
       "<x=4, y=-8, z=8>",
       "<x=3, y=5, z=-1>"
     ], 10, 179, 2772},
    {[
       "<x=-8, y=-10, z=0>",
       "<x=5, y=5, z=10>",
       "<x=2, y=-7, z=3>",
       "<x=9, y=-8, z=-3>"
     ], 100, 1940, 4_686_774_924}
  ]

  for {system, steps, expected_energy, expected_steps} <- @parameters do
    test "AdventOfCode2019.TheNBodyProblem.part1##{steps} == #{expected_energy}" do
      assert AdventOfCode2019.TheNBodyProblem.part1(unquote(system), unquote(steps)) ==
               unquote(expected_energy)
    end

    test "AdventOfCode2019.TheNBodyProblem.part2##{expected_steps} == #{expected_steps}" do
      assert AdventOfCode2019.TheNBodyProblem.part2(unquote(system)) ==
               unquote(expected_steps)
    end
  end
end
