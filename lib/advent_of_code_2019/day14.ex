defmodule AdventOfCode2019.SpaceStoichiometry do
  @moduledoc """
  Day 14 — https://adventofcode.com/2019/day/14
  """

  @spec part1(Enumerable.t()) :: integer
  def part1(in_stream) do
    in_stream
    |> read_reactions()
    |> produce(1)
  end

  @spec part2(Enumerable.t(), integer) :: integer
  def part2(in_stream, ore_amount \\ 1_000_000_000_000) do
    reactions = read_reactions(in_stream)

    produce(reactions, 1)
    |> ballpark(ore_amount)
    |> narrow_down(ore_amount, reactions)
  end

  @spec read_reactions(Enumerable.t()) :: :digraph.graph()
  defp read_reactions(in_stream) do
    in_stream
    |> Enum.reduce(:digraph.new(), &read_reactions/2)
  end

  @spec read_reactions(String.t(), :digraph.graph()) :: :digraph.graph()
  defp read_reactions(line, reactions) do
    [reagents, product] =
      String.trim(line)
      |> String.split(" => ")

    {amount, chemical} = parse_amount_chemical(product)
    :digraph.add_vertex(reactions, chemical)

    String.split(reagents, ", ")
    |> Enum.map(&parse_amount_chemical/1)
    |> read_reactions(amount, chemical, reactions)
  end

  @spec read_reactions(list, integer, String.t(), :digraph.graph()) :: :digraph.graph()
  defp read_reactions([], _amount, _chem, reactions), do: reactions

  defp read_reactions([{r_amnt, r_chem} | reagents], amount, chemical, reactions) do
    :digraph.add_vertex(reactions, r_chem)
    :digraph.add_edge(reactions, chemical, r_chem, {amount, r_amnt, r_amnt})
    read_reactions(reagents, amount, chemical, reactions)
  end

  @spec parse_amount_chemical(String.t()) :: {integer, String.t()}
  defp parse_amount_chemical(amount_chemical) do
    [a, c] = String.split(amount_chemical)
    {String.to_integer(a), c}
  end

  @spec produce(:digraph.graph(), integer) :: integer
  defp produce(reactions, amount) do
    :digraph_utils.topsort(reactions)
    |> produce(reactions, amount)
  end

  @spec produce(list, :digraph.graph(), integer) :: integer
  defp produce(["ORE"], reactions, _amount), do: in_amount("ORE", reactions)

  defp produce(["FUEL" | tail], reactions, amount) do
    update_out_amounts(amount, "FUEL", reactions)
    produce(tail, reactions, amount)
  end

  defp produce([chemical | tail], reactions, amount) do
    in_amount(chemical, reactions)
    |> update_out_amounts(chemical, reactions)

    produce(tail, reactions, amount)
  end

  @spec in_amount(String.t(), :digraph.graph()) :: integer
  defp in_amount(chemical, reactions) do
    :digraph.in_edges(reactions, chemical)
    |> Stream.map(fn e -> :digraph.edge(reactions, e) end)
    |> Stream.map(fn {_, _, _, {_, _, amount}} -> amount end)
    |> Enum.sum()
  end

  @spec update_out_amounts(integer, String.t(), :digraph.graph()) :: :ok
  defp update_out_amounts(in_amount, chemical, reactions) do
    :digraph.out_edges(reactions, chemical)
    |> update_out_amount(in_amount, reactions)
  end

  @spec update_out_amounts(list, integer, :digraph.graph()) :: :ok
  defp update_out_amount([], _in_amount, _reactions), do: :ok

  defp update_out_amount([e | tail], in_amount, reactions) do
    {e, u, v, {in_a, out_a, _}} = :digraph.edge(reactions, e)
    :digraph.del_edge(reactions, e)
    multiplier = ceil(in_amount / in_a)
    :digraph.add_edge(reactions, u, v, {in_a, out_a, multiplier * out_a})
    update_out_amount(tail, in_amount, reactions)
  end

  @spec ballpark(integer, integer) :: {integer, integer}
  defp ballpark(ore_per_fuel, ore_amount) do
    ballpark = ore_amount / ore_per_fuel
    {ceil(ballpark - ballpark / 2), floor(ballpark + ballpark / 2)}
  end

  @spec narrow_down({integer, integer}, integer, :digraph.graph()) :: integer
  defp narrow_down({min_fuel, max_fuel}, max_ore, reactions) do
    fuel = round((min_fuel + max_fuel) / 2)

    produce(reactions, fuel)
    |> narrow_down({min_fuel, max_fuel}, max_ore, fuel, reactions)
  end

  @spec narrow_down(integer, {integer, integer}, integer, integer, :digraph.graph()) :: integer
  defp narrow_down(_ore, {max_fuel, max_fuel}, _max_ore, _fuel, _reactions), do: max_fuel

  defp narrow_down(ore, {_, max_fuel}, max_ore, min_fuel, reactions) when ore < max_ore do
    fuel = round((min_fuel + max_fuel) / 2)

    produce(reactions, fuel)
    |> narrow_down({min_fuel, max_fuel}, max_ore, fuel, reactions)
  end

  defp narrow_down(_ore, {min_fuel, _}, max_ore, max_fuel, reactions) do
    fuel = round((min_fuel + max_fuel - 1) / 2)

    produce(reactions, fuel)
    |> narrow_down({min_fuel, max_fuel - 1}, max_ore, fuel, reactions)
  end
end
