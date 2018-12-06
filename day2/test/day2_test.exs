defmodule Day2Test do
  use ExUnit.Case
  doctest Day2

  test "count_characters" do
    assert Day2.count_characters("aabbccc") == %{
             ?a => 2,
             ?b => 2,
             ?c => 3
           }
  end
end
