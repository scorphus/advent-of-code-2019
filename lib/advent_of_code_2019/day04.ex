defmodule SecureContainer do
  @moduledoc """
  Day 4 — https://adventofcode.com/2019/day/4
  """

  @doc """
  iex> ["111111,223450"] |> SecureContainer.part1()
  1385
  """
  @spec part1(Enumerable.t()) :: integer()
  def part1(in_stream) do
    in_stream
    |> Stream.map(&read_password/1)
    |> Enum.take(1)
    |> List.first()
    |> count_passwords()
  end

  @doc """
  iex> ["111111,223450"] |> SecureContainer.part2()
  981
  """
  @spec part2(Enumerable.t()) :: integer()
  def part2(in_stream) do
    in_stream
    |> Stream.map(&read_password/1)
    |> Enum.take(1)
    |> List.first()
    |> count_passwords2()
  end

  @spec read_password(Enumerable.t()) :: Enumerable.t()
  defp read_password(line) do
    line
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  @spec count_passwords(Enumerable.t()) :: integer()
  defp count_passwords([start, finish]) when start <= finish do
    is_password(Integer.digits(start), 0) + count_passwords([start + 1, finish])
  end

  defp count_passwords(_), do: 0

  @spec is_password(Enumerable.t(), integer()) :: integer()
  defp is_password([], eq_adj), do: eq_adj
  defp is_password([head | [tail | _]], _) when head > tail, do: 0
  defp is_password([head | [head | tail]], _), do: is_password([head | tail], 1)
  defp is_password([_ | tail], eq_adj), do: is_password(tail, eq_adj)

  @spec count_passwords2(Enumerable.t()) :: integer()
  def count_passwords2([start, finish]) when start <= finish do
    is_password2(Integer.digits(start), 0) + count_passwords2([start + 1, finish])
  end

  def count_passwords2(_), do: 0

  @spec is_password2(Enumerable.t(), integer()) :: integer()
  defp is_password2([], eq_adj), do: eq_adj
  defp is_password2([head | [tail | _]], _) when head > tail, do: 0
  defp is_password2([head | [head | [head | [head | [head, head]]]]], _), do: 0

  defp is_password2([head | [head | [head | [head | [head | tail]]]]], _),
    do: is_password2([head | tail], 0)

  defp is_password2([head | [head | [head | [head | tail]]]], eq_adj),
    do: is_password2([head | tail], eq_adj)

  defp is_password2([head | [head | [head | tail]]], eq_adj),
    do: is_password2([head | tail], eq_adj)

  defp is_password2([head | [head | tail]], _), do: is_password2([head | tail], 1)
  defp is_password2([_ | tail], eq_adj), do: is_password2(tail, eq_adj)
end
