defmodule Day5 do
  @doc """

    Examples:
      iex> Day5.react("dabAcCaCBAcCcaDA")
      "dabCBAcaDA"

      iex> Day5.react("aabAAB")
      "aabAAB"
  """
  def react(polymer) when is_binary(polymer),
    do: react_and_discard(polymer, [], nil, nil)

  @doc """

    Examples:
      iex> Day5.react_and_discard("dabAcCaCBAcCcaDA", ?A, ?a)
      "dbCBcD"
  """
  def react_and_discard(polymer, letter1, letter2) when is_binary(polymer),
    do: react_and_discard(polymer, [], letter1, letter2)

  def react_and_discard(<<letter1, rest::binary>>, acc, discard1, discard2)
      when letter1 == discard1 or letter1 == discard2,
      do: react_and_discard(rest, acc, discard1, discard2)

  def react_and_discard(<<letter1, rest::binary>>, [letter2 | acc], discard1, discard2)
      when abs(letter1 - letter2) == 32,
      do: react_and_discard(rest, acc, discard1, discard2)

  def react_and_discard(<<letter1, rest::binary>>, acc, discard1, discard2),
    do: react_and_discard(rest, [letter1 | acc], discard1, discard2)

  def react_and_discard(<<>>, acc, _discard1, _discard2),
    do: acc |> Enum.reverse() |> List.to_string()

  @doc """
    Examples:
      iex> Day5.find_problematic_unit("dabAcCaCBAcCcaDA")
      {?C, 4}
  """
  def find_problematic_unit(polymer) do
    ?A..?Z
    |> Task.async_stream(
      fn letter ->
        {letter, byte_size(react_and_discard(polymer, letter, letter + 32))}
      end,
      ordered: false,
      max_concurrency: 26
    )
    |> Stream.map(fn {:ok, res} -> res end)
    |> Enum.min_by(&elem(&1, 1))
  end
end
