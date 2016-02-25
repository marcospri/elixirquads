defmodule Elixirquads.Mixfile do
  use Mix.Project

  def project do
    [app: :elixirquads,
     version: "0.0.1",
     elixir: "~> 1.0",
     escript: [main_module: Quads], 
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:mogrify, "~> 0.2"}
    ]
  end
end
