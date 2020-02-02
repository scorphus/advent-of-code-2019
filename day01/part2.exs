defmodule RocketEquation do
  def main do
    IO.gets("")
    |> read_modules()
    |> fuel_requirements()
    |> IO.inspect(label: "fuel required")
  end

  defp read_modules(:eof), do: []
  defp read_modules(module) do
    read_modules(IO.gets("")) ++ [String.to_integer(String.trim(module))]
  end

  defp fuel_requirements([]), do: 0
  defp fuel_requirements([module | _]) when module < 9, do: 0
  defp fuel_requirements([module | modules]) do
    fuel = div(module, 3) - 2
    fuel + fuel_requirements([fuel]) + fuel_requirements(modules)
  end

end

RocketEquation.main()
