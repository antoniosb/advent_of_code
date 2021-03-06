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
  ...>  [1, 1, 3, 4, 4],
  ...>  [2, 3, 1, 4, 4],
  ...>  [3, 5, 5, 2, 2],
  ...> ])
  iex> :ets.lookup_element(claimed, {4,2}, 2)
  [2]
  iex> :ets.lookup_element(claimed, {4,4}, 2) |> Enum.sort()
  [1, 2]

  """
  @spec claimed_inches([parsed_claim]) :: :ets.tab()
  def claimed_inches(parsed_claims) do
    table = :ets.new(:claimed_inches, [:duplicate_bag, :private])

    for [id, left, top, width, height] <- parsed_claims,
        x <- (left + 1)..(left + width),
        y <- (top + 1)..(top + height) do
      :ets.insert(table, {{x, y}, id})
    end

    table

    # Enum.reduce(parsed_claims, %{}, fn [id, left, top, width, height], acc ->
    #   Enum.reduce((left + 1)..(left + width), acc, fn x, acc ->
    #     Enum.reduce((top + 1)..(top + height), acc, fn y, acc ->
    #       Map.update(acc, {x, y}, [id], &[id | &1])
    #     end)
    #   end)
    # end)
  end

  @doc """
  Retrieves overlapped inches.

  ## Examples:

    iex> Day3.overlapped_inches([
    ...>  [1, 1, 3, 4, 4],
    ...>  [2, 3, 1, 4, 4],
    ...>  [3, 5, 5, 2, 2],
    ...> ]) |> Enum.sort()
    [{4,4}, {4,5}, {5,4}, {5,5}]
  """
  # @spec overlapped_inches([parsed_claim]) :: [coordinate]
  # def overlapped_inches(parsed_claims) do
  #   :ets.select(claimed_inches(parsed_claims), [
  #     {{:"$1", :"$2"}, [{:>, {:length, :"$2"}, 1}], [:"$1"]}
  #   ])

  #   # for {coordinate, [_, _ | _]} <- claimed_inches(parsed_claims), do: coordinate
  # end

  @doc """
    Find non overlapping claim

    ## Examples:

      iex> Day3.non_overlapping_claim([
      ...>  "#1 @ 1,3: 4x4",
      ...>  "#2 @ 3,1: 4x4",
      ...>  "#3 @ 5,5: 2x2",
      ...> ])
      3
  """
  @spec non_overlapping_claim([claim]) :: id
  def non_overlapping_claim(claims) do
    parsed_claims = Enum.map(claims, &parse_claim/1)

    claimed_inches = claimed_inches(parsed_claims)

    [id, _, _, _, _] =
      Enum.find(parsed_claims, fn [id, left, top, width, height] ->
        Enum.all?((left + 1)..(left + width), fn x ->
          Enum.all?((top + 1)..(top + height), fn y ->
            # Map.get(claimed_inches, {x, y}) == [id]
            :ets.lookup_element(claimed_inches, {x, y}, 2) == [id]
          end)
        end)
      end)

    id
  end
end
