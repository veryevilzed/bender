defmodule Bender.Mixfile do
  use Mix.Project

  def project() do
    [app: :bender,
     version: "0.0.1",
     elixir: "~> 1.14.0",
     deps: []]
  end

  def application() do
    [applications: [:logger]]
  end
end
