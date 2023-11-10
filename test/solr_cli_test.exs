defmodule SolrCliTest do
  use ExUnit.Case
  doctest SolrCli

  test "greets the world" do
    assert SolrCli.hello() == :world
  end
end
