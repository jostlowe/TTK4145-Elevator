defmodule TestHeisTest do
  use ExUnit.Case
  doctest TestHeis

  test "greets the world" do
    assert TestHeis.hello() == :world
  end
end
