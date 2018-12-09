defmodule FrequencyMap do
  defstruct data: %{}

  def new do
    %FrequencyMap{}
  end

  def most_frequent(%FrequencyMap{data: data}) do
    {key, _} =
      Enum.max_by(data, fn {_, count} ->
        count
      end)

    key
  end

  defimpl Collectable do
    def into(%FrequencyMap{data: data}) do
      collector_fun = fn
        data, {:cont, elem} -> Map.update(data, elem, 1, &(&1 + 1))
        data, :done -> %FrequencyMap{data: data}
        _data, :halt -> :ok
      end

      {data, collector_fun}
    end
  end
end

defmodule Day4 do
  import NimbleParsec

  guard_command =
    ignore(string("Guard #"))
    |> integer(min: 1)
    |> ignore(string(" begins shift"))
    |> unwrap_and_tag(:shift)

  sleep_command = string("falls asleep") |> replace(:down)

  wakeup_command = string("wakes up") |> replace(:up)

  defparsecp(
    :parsec_log,
    ignore(string("["))
    |> integer(4)
    |> ignore(string("-"))
    |> integer(2)
    |> ignore(string("-"))
    |> integer(2)
    |> ignore(string(" "))
    |> integer(2)
    |> ignore(string(":"))
    |> integer(2)
    |> ignore(string("] "))
    |> choice([
      guard_command,
      sleep_command,
      wakeup_command
    ])
  )

  def parse_log(input) when is_binary(input) do
    {:ok, [year, month, day, hour, minute, id], "", _, _, _} = parsec_log(input)

    {{year, month, day}, hour, minute, id}
  end

  def group_by_id_and_date(unsorted_logs_as_strings) do
    unsorted_logs_as_strings
    |> Enum.map(&parse_log/1)
    |> Enum.sort()
    |> group_by_id_and_date([])
  end

  defp group_by_id_and_date([{date, _hour, _minute, {:shift, id}} | rest], groups) do
    {rest, ranges} = get_asleep_ranges(rest, [])
    group_by_id_and_date(rest, [{id, date, ranges} | groups])
  end

  defp group_by_id_and_date([], groups) do
    Enum.reverse(groups)
  end

  defp get_asleep_ranges(
         [{_, _, down_minute, :down}, {_, _, up_minute, :up} | rest],
         ranges
       ) do
    get_asleep_ranges(rest, [down_minute..(-1 + up_minute) | ranges])
  end

  defp get_asleep_ranges(rest, ranges) do
    {rest, Enum.reverse(ranges)}
  end

  def sum_asleep_times_by_id(grouped_entries) do
    Enum.reduce(grouped_entries, %{}, fn {id, _date, ranges}, acc ->
      time_asleep = ranges |> Enum.map(&Enum.count/1) |> Enum.sum()
      Map.update(acc, id, time_asleep, &(&1 + time_asleep))
    end)
  end

  def id_asleep_the_most(map) do
    {id, _} =
      Enum.max_by(map, fn {_, time_asleep} ->
        time_asleep
      end)

    id
  end

  def minute_asleep_the_most_by_id(list, id) do
    frequency_map =
      for {^id, _, ranges} <- list,
          range <- ranges,
          minute <- range,
          do: minute,
          into: FrequencyMap.new()

    FrequencyMap.most_frequent(frequency_map)
  end

  def part_one(input) do
    grouped_entries =
      input
      |> File.read!()
      |> String.split("\n", trim: true)
      |> group_by_id_and_date()

    id_asleep_the_most =
      grouped_entries
      |> sum_asleep_times_by_id()
      |> id_asleep_the_most

    minute_asleep_the_most = minute_asleep_the_most_by_id(grouped_entries, id_asleep_the_most)

    id_asleep_the_most * minute_asleep_the_most
  end
end
