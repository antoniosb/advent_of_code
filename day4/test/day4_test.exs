defmodule Day4Test do
  use ExUnit.Case
  doctest Day4

  test "parses the input" do
    assert Day4.parse_log("[1518-11-01 00:00] Guard #10 begins shift") ==
             {{1518, 11, 01}, 00, 00, 10}

    assert Day4.parse_log("[1518-11-01 00:05] falls asleep") == {{1518, 11, 01}, 00, 05, :down}

    assert Day4.parse_log("[1518-11-01 00:25] wakes up") == {{1518, 11, 01}, 00, 25, :up}
  end
end
