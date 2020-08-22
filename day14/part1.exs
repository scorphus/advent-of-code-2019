defmodule SpaceStoichiometry do
  def main do
    read_reactions()
    |> produce()
    |> IO.inspect(label: "Minimum amount of ORE required to produce exactly 1 FUEL")
  end

  defp read_reactions() do
    IO.gets("")
    |> read_reactions(:digraph.new())
  end

  defp read_reactions(:eof, reactions), do: reactions

  defp read_reactions(line, reactions) do
    [reagents, product] =
      line
      |> String.trim()
      |> String.split(" => ")

    {amount, chemical} =
      product
      |> parse_amount_chemical()

    :digraph.add_vertex(reactions, chemical)

    reagents
    |> String.split(", ")
    |> Enum.map(&parse_amount_chemical/1)
    |> read_reactions(amount, chemical, reactions)
  end

  defp read_reactions([], _amount, _chem, reactions) do
    IO.gets("")
    |> read_reactions(reactions)
  end

  defp read_reactions([{r_amnt, r_chem} | reagents], amount, chemical, reactions) do
    :digraph.add_vertex(reactions, r_chem)
    :digraph.add_edge(reactions, chemical, r_chem, {amount, r_amnt})
    read_reactions(reagents, amount, chemical, reactions)
  end

  defp parse_amount_chemical(amount_chemical) do
    [a, c] = String.split(amount_chemical, " ")
    {String.to_integer(a), c}
  end

  defp produce(reactions) do
    :digraph_utils.topsort(reactions)
    |> produce(reactions)
  end

  defp produce(["ORE"], reactions), do: in_amount("ORE", reactions)
  defp produce(["FUEL" | tail], reactions), do: produce(tail, reactions)

  defp produce([chemical | tail], reactions) do
    in_amount(chemical, reactions)
    |> update_out_amounts(chemical, reactions)

    produce(tail, reactions)
  end

  defp in_amount(chemical, reactions) do
    :digraph.in_edges(reactions, chemical)
    |> Stream.map(fn e -> :digraph.edge(reactions, e) end)
    |> Stream.map(fn {_, _, _, {_, a}} -> a end)
    |> Enum.sum()
  end

  defp update_out_amounts(in_amount, chemical, reactions) do
    :digraph.out_edges(reactions, chemical)
    |> update_out_amount(in_amount, reactions)
  end

  defp update_out_amount([], _in_amount, _reactions), do: :ok

  defp update_out_amount([e | tail], in_amount, reactions) do
    {e, u, v, {in_a, out_a}} = :digraph.edge(reactions, e)
    :digraph.del_edge(reactions, e)
    multiplier = ceil(in_amount / in_a)
    :digraph.add_edge(reactions, u, v, {multiplier * in_a, multiplier * out_a})
    update_out_amount(tail, in_amount, reactions)
  end
end

SpaceStoichiometry.main()
