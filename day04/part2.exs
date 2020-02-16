defmodule SecureContainer do
  def count_passwords([start, finish]) when start <= finish do
    is_password(Integer.digits(start), 0) + count_passwords([start + 1, finish])
  end

  def count_passwords(_), do: 0

  defp is_password([], eq_adj), do: eq_adj
  defp is_password([head | [tail | _]], _) when head > tail, do: 0
  defp is_password([head | [head | [head | [head | [head, head]]]]], _), do: 0

  defp is_password([head | [head | [head | [head | [head | tail]]]]], _),
    do: is_password([head | tail], 0)

  defp is_password([head | [head | [head | [head | tail]]]], eq_adj),
    do: is_password([head | tail], eq_adj)

  defp is_password([head | [head | [head | tail]]], eq_adj), do: is_password([head | tail], eq_adj)
  defp is_password([head | [head | tail]], _), do: is_password([head | tail], 1)
  defp is_password([_ | tail], eq_adj), do: is_password(tail, eq_adj)
end

System.argv()
|> Enum.map(&String.to_integer/1)
|> SecureContainer.count_passwords()
|> IO.inspect(label: "Number of different passwords")
