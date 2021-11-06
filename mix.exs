defmodule AdventOfCode2019.MixProject do
  use Mix.Project

  def project do
    [
      app: :advent_of_code_2019,
      version: "0.1.0",
      elixir: "~> 1.10",
      escript: [main_module: AdventOfCode2019.CLI],
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
      ],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.html": :test,
        "coveralls.json": :test
      ],
      test_coverage: [tool: ExCoveralls]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.5.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:excoveralls, "~> 0.5.7", only: :test},
      {:mock, "~> 0.3.0", only: :test}
    ]
  end
end
