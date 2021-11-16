defmodule AdventOfCode2019.FlawedFrequencyTransmissionTest do
  use ExUnit.Case

  @parameters_part1 [
    {["80871224585914546619083218645595"], "24176176"},
    {["19617804207202209144916044189917"], "73745418"},
    {["69317163492948606335995924319873"], "52432133"}
  ]

  for {input_signal, digits} <- @parameters_part1 do
    test "AdventOfCode2019.FlawedFrequencyTransmission.part1##{input_signal} == ##{digits}" do
      assert AdventOfCode2019.FlawedFrequencyTransmission.part1(unquote(input_signal)) ==
               unquote(digits)
    end
  end

  @parameters_part2 [
    {["03036732577212944063491565474664"], "84462026"},
    {["02935109699940807407585447034323"], "78725270"},
    {["03081770884921959731165446850517"], "53553731"}
  ]

  for {input_signal, digits} <- @parameters_part2 do
    test "AdventOfCode2019.FlawedFrequencyTransmission.part2##{input_signal} == ##{digits}" do
      assert AdventOfCode2019.FlawedFrequencyTransmission.part2(unquote(input_signal)) ==
               unquote(digits)
    end
  end
end
