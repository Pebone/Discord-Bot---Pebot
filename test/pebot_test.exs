defmodule PebotTest do
  use ExUnit.Case
  doctest Pebot

  test "greets the world" do
    assert Pebot.hello() == :world
  end
end
