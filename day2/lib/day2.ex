defmodule Day2 do
  def closest([head | tail]) do
    if closest = Enum.find(tail, &one_char_difference?(&1, head)) do
      # common_prefix_and_suffix()
      charlist1 = String.to_charlist(head)
      charlist2 = String.to_charlist(closest)

      charlist1
      |> Enum.zip(charlist2)
      |> Enum.filter(fn {cp1, cp2} -> cp1 == cp2 end)
      |> Enum.map(fn {cp, _} -> cp end)
      |> List.to_string()
    else
      closest(tail)
    end
  end

  defp one_char_difference?(string1, string2) do
    charlist1 = String.to_charlist(string1)
    charlist2 = String.to_charlist(string2)

    charlist1
    |> Enum.zip(charlist2)
    |> Enum.count(fn {cp1, cp2} -> cp1 != cp2 end)
    |> Kernel.==(1)
  end

  def checksum(list) when is_list(list) do
    {twices, thrices} =
      Enum.reduce(list, {0, 0}, fn box_id, {total_twice, total_thrice} ->
        {twice, thrice} = box_id |> count_characters() |> get_twice_and_thrice()
        {twice + total_twice, thrice + total_thrice}
      end)

    twices * thrices
  end

  def get_twice_and_thrice(characters) when is_map(characters) do
    Enum.reduce(characters, {0, 0}, fn
      {_codepoint, 2}, {_twice, thrice} -> {1, thrice}
      {_codepoint, 3}, {twice, _thrice} -> {twice, 1}
      _, acc -> acc
    end)
  end

  def count_characters(string) when is_binary(string) do
    count_characters(string, %{})
  end

  defp count_characters(<<codepoint::utf8, rest::binary>>, acc) do
    acc = Map.update(acc, codepoint, 1, &(&1 + 1))
    count_characters(rest, acc)
  end

  defp count_characters(<<>>, acc) do
    acc
  end
end
