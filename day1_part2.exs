defmodule Day1 do
  def repeated_frequency(file_stream) do
    file_stream
    |> Stream.map(fn line ->
      {integer, _leftover} = Integer.parse(line)
      integer
    end)
    |> Stream.cycle()
    |> Enum.reduce_while({0, []}, fn x, {current_freq, seen_freq} ->
      new_freq = current_freq + x

      if new_freq in seen_freq do
        {:halt, new_freq}
      else
        {:cont, {new_freq, [new_freq | seen_freq]}}
      end
    end)
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day1Test do
      use ExUnit.Case

      import Day1

      test "final frequency" do
        assert repeated_frequency([
                 "+1\n",
                 "-2\n",
                 "+3\n",
                 "+1\n"
               ]) == 2
      end
    end

  [input_file] ->
    input_file
    |> File.stream!([], :line)
    |> Day1.repeated_frequency()
    |> IO.puts()

  _ ->
    IO.puts(:stderr, "expected --test or input file")
    System.halt(1)
end
