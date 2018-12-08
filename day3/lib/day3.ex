defmodule Day3 do
  @type claim :: String.t()
  @type parsed_claim :: list
  @type coordinate :: {pos_integer, pos_integer}
  @type id :: integer

  @doc """
  Parses a claim.

  ## Examples:

    iex> Day3.parse_claim("#1 @ 286,440: 19x24")
    [1, 286, 440, 19, 24]
  """
  def parse_claim(string) when is_binary(string) do
    string
    |> String.split(["#", " @ ", ",", ": ", "x"], trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  @doc """
  Retrieve all claimed inches.

  ## Examples:

    iex> claimed = Day3.claimed_inches([
    ...>  "#1 @ 1,3: 4x4",
    ...>  "#2 @ 3,1: 4x4",
    ...>  "#3 @ 5,5: 2x2",
    ...> ])
    iex> claimed[{4,2}]
    [2]

  """
  @spec claimed_inches([claim]) :: %{coordinate => [id]}
  def claimed_inches(claims) do
    Enum.reduce(claims, %{}, fn claim, acc ->
      [id, left, top, width, height] = parse_claim(claim)

      Enum.reduce((left + 1)..(left + width), acc, fn x, acc ->
        Enum.reduce((top + 1)..(top + height), acc, fn y, acc ->
          Map.update(acc, {x, y}, [id], &[id | &1])
        end)
      end)
    end)
  end
end
