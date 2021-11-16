defmodule AdventOfCode2019 do
  @moduledoc """
  AdventOfCode2019 is a a set of solutions to Advent of Code 2019 in Elixir!
  """

  @doc """
  Run the specified day with supplied input.

  Example:

  iex> ["12", "14", "1969", "100756"] |> AdventOfCode2019.stream_lines("1.1")
  34_241

  """
  @spec stream_lines(Enumerable.t(), String.t()) :: integer()
  def stream_lines(in_stream, day_part), do: run_day_part(in_stream, day_part)

  @spec run_day_part(Enumerable.t(), String.t()) :: integer()
  defp run_day_part(in_stream, "1.1"), do: RocketEquation.part1(in_stream)
  defp run_day_part(in_stream, "1.2"), do: RocketEquation.part2(in_stream)
  defp run_day_part(in_stream, "2.1"), do: TwelveOhTwoProgramAlarm.part1(in_stream)
  defp run_day_part(in_stream, "2.2"), do: TwelveOhTwoProgramAlarm.part2(in_stream)
  defp run_day_part(in_stream, "3.1"), do: CrossedWires.part1(in_stream)
  defp run_day_part(in_stream, "3.2"), do: CrossedWires.part2(in_stream)
  defp run_day_part(in_stream, "4.1"), do: SecureContainer.part1(in_stream)
  defp run_day_part(in_stream, "4.2"), do: SecureContainer.part2(in_stream)
  defp run_day_part(in_stream, "5.1"), do: SunnyWithAsteroids.part1(in_stream)
  defp run_day_part(in_stream, "5.2"), do: SunnyWithAsteroids.part2(in_stream)
  defp run_day_part(in_stream, "6.1"), do: UniversalOrbitMap.part1(in_stream)
  defp run_day_part(in_stream, "6.2"), do: UniversalOrbitMap.part2(in_stream)
  defp run_day_part(in_stream, "7.1"), do: AdventOfCode2019.AmplificationCircuit.part1(in_stream)
  defp run_day_part(in_stream, "7.2"), do: AdventOfCode2019.AmplificationCircuit.part2(in_stream)
  defp run_day_part(in_stream, "8.1"), do: AdventOfCode2019.SpaceImageFormat.part1(in_stream)
  defp run_day_part(in_stream, "8.2"), do: AdventOfCode2019.SpaceImageFormat.part2(in_stream)
  defp run_day_part(in_stream, "9.1"), do: AdventOfCode2019.SensorBoost.part1(in_stream)
  defp run_day_part(in_stream, "9.2"), do: AdventOfCode2019.SensorBoost.part2(in_stream)
  defp run_day_part(in_stream, "10.1"), do: AdventOfCode2019.MonitoringStation.part1(in_stream)
  defp run_day_part(in_stream, "10.2"), do: AdventOfCode2019.MonitoringStation.part2(in_stream)
  defp run_day_part(in_stream, "11.1"), do: AdventOfCode2019.SpacePolice.part1(in_stream)
  defp run_day_part(in_stream, "11.2"), do: AdventOfCode2019.SpacePolice.part2(in_stream)
  defp run_day_part(in_stream, "12.1"), do: AdventOfCode2019.TheNBodyProblem.part1(in_stream)
  defp run_day_part(in_stream, "12.2"), do: AdventOfCode2019.TheNBodyProblem.part2(in_stream)
  defp run_day_part(in_stream, "13.1"), do: AdventOfCode2019.CarePackage.part1(in_stream)
  defp run_day_part(in_stream, "13.2"), do: AdventOfCode2019.CarePackage.part2(in_stream)
  defp run_day_part(in_stream, "14.1"), do: AdventOfCode2019.SpaceStoichiometry.part1(in_stream)
  defp run_day_part(in_stream, "14.2"), do: AdventOfCode2019.SpaceStoichiometry.part2(in_stream)
  defp run_day_part(in_stream, "15.1"), do: AdventOfCode2019.OxygenSystem.part1(in_stream)
  defp run_day_part(in_stream, "15.2"), do: AdventOfCode2019.OxygenSystem.part2(in_stream)

  defp run_day_part(in_stream, "16.1"),
    do: AdventOfCode2019.FlawedFrequencyTransmission.part1(in_stream)

  defp run_day_part(in_stream, "16.2"),
    do: AdventOfCode2019.FlawedFrequencyTransmission.part2(in_stream)
end
