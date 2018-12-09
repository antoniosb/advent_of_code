defmodule Day4Test do
  use ExUnit.Case
  doctest Day4

  test "parses the input" do
    assert Day4.parse_log("[1518-11-01 00:00] Guard #10 begins shift") ==
             {{1518, 11, 01}, 00, 00, {:shift, 10}}

    assert Day4.parse_log("[1518-11-01 00:05] falls asleep") == {{1518, 11, 01}, 00, 05, :down}

    assert Day4.parse_log("[1518-11-01 00:25] wakes up") == {{1518, 11, 01}, 00, 25, :up}
  end

  test "groups input by id and date" do
    input = [
      "[1518-11-04 00:46] wakes up",
      "[1518-11-01 00:55] wakes up",
      "[1518-11-04 00:36] falls asleep",
      "[1518-11-03 00:24] falls asleep",
      "[1518-11-05 00:03] Guard #99 begins shift",
      "[1518-11-01 00:25] wakes up",
      "[1518-11-01 00:00] Guard #10 begins shift",
      "[1518-11-05 00:55] wakes up",
      "[1518-11-04 00:02] Guard #99 begins shift",
      "[1518-11-03 00:29] wakes up",
      "[1518-11-03 00:05] Guard #10 begins shift",
      "[1518-11-01 23:58] Guard #99 begins shift",
      "[1518-11-01 00:30] falls asleep",
      "[1518-11-02 00:40] falls asleep",
      "[1518-11-01 00:05] falls asleep",
      "[1518-11-02 00:50] wakes up",
      "[1518-11-05 00:45] falls asleep"
    ]

    assert Day4.group_by_id_and_date(input) ==
             [
               {10, {1518, 11, 1}, [5..24, 30..54]},
               {99, {1518, 11, 1}, [40..49]},
               {10, {1518, 11, 3}, [24..28]},
               {99, {1518, 11, 4}, [36..45]},
               {99, {1518, 11, 5}, [45..54]}
             ]
  end

  test "sums the asleep time from grouped entries" do
    input = [
      {10, {1518, 11, 1}, [5..24, 30..54]},
      {99, {1518, 11, 1}, [40..49]},
      {10, {1518, 11, 3}, [24..28]},
      {99, {1518, 11, 4}, [36..45]},
      {99, {1518, 11, 5}, [45..54]}
    ]

    assert Day4.sum_asleep_times_by_id(input) == %{
             10 => 50,
             99 => 30
           }
  end

  test "returns the id of with the max value asleep" do
    input = %{
      10 => 50,
      99 => 30
    }

    assert Day4.id_asleep_the_most(input) == 10
  end

  test "returns the minute most frequent on the ranges of the given id" do
    input = [
      {10, {1518, 11, 1}, [5..24, 30..54]},
      {99, {1518, 11, 1}, [40..49]},
      {10, {1518, 11, 3}, [24..28]},
      {99, {1518, 11, 4}, [36..45]},
      {99, {1518, 11, 5}, [45..54]}
    ]

    assert Day4.minute_asleep_the_most_by_id(input, 10) == 24
  end
end
