defmodule FrequencyMap do
  defstruct data: %{}

  def new do
    %FrequencyMap{}
  end

  def most_frequent(%FrequencyMap{data: data}) do
    if data != %{} do
      Enum.max_by(data, fn {_, count} -> count end)
    else
      :error
    end
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

  def minutes_asleep_the_most(grouped_entries) do
    {current_id, current_minute, _, _} =
      Enum.reduce(grouped_entries, {0, 0, 0, MapSet.new()}, fn {id, _, _}, acc ->
        {current_id, current_minute, current_count, seen_ids} = acc

        # with false <- id in seen_ids,
        #      {minute, count} when count > current_count <-
        #        minute_asleep_the_most_by_id(grouped_entries, id) do
        #   {id, minute, count, MapSet.put(seen_ids, id)}
        # else
        #   _ ->
        #     {current_id, current_minute, current_count, MapSet.put(seen_ids, id)}
        # end

        if(id in seen_ids) do
          acc
        else
          case(minute_asleep_the_most_by_id(grouped_entries, id)) do
            :error ->
              {current_id, current_minute, current_count, MapSet.put(seen_ids, id)}

            {minute, count} when count > current_count ->
              {id, minute, count, MapSet.put(seen_ids, id)}

            _ ->
              {current_id, current_minute, current_count, MapSet.put(seen_ids, id)}
          end
        end
      end)

    {current_id, current_minute}
  end

  def minute_asleep_the_most_by_id(grouped_entries, id) do
    frequency_map =
      for {^id, _, ranges} <- grouped_entries,
          range <- ranges,
          minute <- range,
          do: minute,
          into: FrequencyMap.new()

    FrequencyMap.most_frequent(frequency_map)
  end

  @doc """
    Entry point for part one.
  """
  def part_one(input) do
    grouped_entries =
      input
      |> group_by_id_and_date_on_input

    id_asleep_the_most =
      grouped_entries
      |> sum_asleep_times_by_id()
      |> id_asleep_the_most

    {minute_asleep_the_most, _} =
      minute_asleep_the_most_by_id(grouped_entries, id_asleep_the_most)

    id_asleep_the_most * minute_asleep_the_most
  end

  @doc """
    Entry point for part two.
  """
  def part_two(input) do
    {id, minute} =
      input
      |> group_by_id_and_date_on_input()
      |> minutes_asleep_the_most()

    id * minute
  end

  defp group_by_id_and_date_on_input(input) do
    input
    |> File.read!()
    |> String.split("\n", trim: true)
    |> group_by_id_and_date()
  end
end
