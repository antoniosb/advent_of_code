defmodule Day4 do
  import NimbleParsec

  def parse_log(input) when is_binary(input) do
    {:ok, [year, month, day, hour, minute, id], "", _, _, _} = parsec_log(input)

    {{year, month, day}, hour, minute, id}
  end

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
end
