defmodule Day5 do
  @moduledoc """

    Examples:
      iex> Day5.react("dabAcCaCBAcCcaDA")
      "dabCBAcaDA"

      iex> Day5.react("aabAAB")
      "aabAAB"
  """
  def react(polymer) when is_binary(polymer),
    do: react(polymer, [])

  def react(<<letter1, rest::binary>>, [letter2 | acc]) when abs(letter1 - letter2) == 32,
    do: react(rest, acc)

  def react(<<letter1, rest::binary>>, acc),
    do: react(rest, [letter1 | acc])

  def react(<<>>, acc),
    do: acc |> Enum.reverse() |> List.to_string()
end
