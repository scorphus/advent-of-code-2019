defmodule SpaceStoichiometry do
  def main do
    ore_amount =
      System.argv()
      |> List.first()
      |> String.to_integer()

    reactions = read_reactions()

    produce(reactions, 1)
    |> IO.inspect(label: "Minimum amount of ORE required to produce exactly 1 FUEL")
    |> ballpark(ore_amount)
    |> narrow_down(ore_amount, reactions)
    |> IO.inspect(label: "Maximum amount of FUEL that can be produced with #{ore_amount} ORE")
  end

  defp read_reactions() do
    IO.gets("")
    |> read_reactions(:digraph.new())
  end

  defp read_reactions(:eof, reactions), do: reactions

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

  defp read_reactions([], _amount, _chem, reactions) do
    IO.gets("")
    |> read_reactions(reactions)
  end

  defp read_reactions([{r_amnt, r_chem} | reagents], amount, chemical, reactions) do
    :digraph.add_vertex(reactions, r_chem)
    :digraph.add_edge(reactions, chemical, r_chem, {amount, r_amnt, r_amnt})
    read_reactions(reagents, amount, chemical, reactions)
  end

  defp parse_amount_chemical(amount_chemical) do
    [a, c] = String.split(amount_chemical)
    {String.to_integer(a), c}
  end

  defp produce(reactions, amount) do
    :digraph_utils.topsort(reactions)
    |> produce(reactions, amount)
  end

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

  defp in_amount(chemical, reactions) do
    :digraph.in_edges(reactions, chemical)
    |> Stream.map(fn e -> :digraph.edge(reactions, e) end)
    |> Stream.map(fn {_, _, _, {_, _, amount}} -> amount end)
    |> Enum.sum()
  end

  defp update_out_amounts(in_amount, chemical, reactions) do
    :digraph.out_edges(reactions, chemical)
    |> update_out_amount(in_amount, reactions)
  end

  defp update_out_amount([], _in_amount, _reactions), do: :ok

  defp update_out_amount([e | tail], in_amount, reactions) do
    {e, u, v, {in_a, out_a, _}} = :digraph.edge(reactions, e)
    :digraph.del_edge(reactions, e)
    multiplier = ceil(in_amount / in_a)
    :digraph.add_edge(reactions, u, v, {in_a, out_a, multiplier * out_a})
    update_out_amount(tail, in_amount, reactions)
  end

  defp ballpark(ore_per_fuel, ore_amount) do
    ballpark = ore_amount / ore_per_fuel
    {ceil(ballpark - ballpark / 2), floor(ballpark + ballpark / 2)}
  end

  defp narrow_down({min_fuel, max_fuel}, max_ore, reactions) do
    fuel = round((min_fuel + max_fuel) / 2)

    produce(reactions, fuel)
    |> narrow_down({min_fuel, max_fuel}, max_ore, fuel, reactions)
  end

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

SpaceStoichiometry.main()
