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

  def group_by_id_and_date_with_sleeping_hours(unsorted_logs_as_strings) do
    unsorted_logs_as_strings
    |> Enum.map(&parse_log/1)
    |> Enum.sort()
    |> compute_sleeping_hours([])
  end

  defp compute_sleeping_hours([{date, _hour, _minute, {:shift, id}} | rest], groups) do
    {rest, ranges} = get_asleep_time(rest, 0)
    compute_sleeping_hours(rest, [{id, date, ranges} | groups])
  end

  defp compute_sleeping_hours([], groups) do
    Enum.reverse(groups)
  end

  defp get_asleep_time(
         [{_, _, down_minute, :down}, {_, _, up_minute, :up} | rest],
         asleep
       ) do
    get_asleep_time(rest, asleep + (up_minute - down_minute))
  end

  defp get_asleep_time(rest, asleep) do
    {rest, asleep}
  end
end
