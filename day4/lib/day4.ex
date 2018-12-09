defmodule Day4 do
  import NimbleParsec

  def parse_log(input) when is_binary(input) do
    {:ok, [year, month, day, hour, minute, id], "", _, _, _} = parsec_log(input)

    {{year, month, day}, hour, minute, id}
  end

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
      ignore(string("Guard #")) |> integer(min: 1) |> ignore(string(" begins shift")),
      string("falls asleep") |> replace(:down),
      string("wakes up") |> replace(:up)
    ])
  )
end
