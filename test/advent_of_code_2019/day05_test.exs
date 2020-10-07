defmodule SunnyWithAsteroidsTest do
  use ExUnit.Case

  doctest SunnyWithAsteroids

  @parameters [
    {[
       "3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99"
     ], 7, 999},
    {[
       "3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99"
     ], 8, 1000},
    {[
       "3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99"
     ], 9, 1001}
  ]

  for {program, input, expected} <- @parameters do
    test "SunnyWithAsteroids.part1##{input} == #{expected}" do
      assert SunnyWithAsteroids.part1(unquote(program), unquote(input)) == unquote(expected)
    end
  end
end
