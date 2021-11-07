defmodule AdventOfCode2019.CLITest do
  use ExUnit.Case

  import Mock

  test "AdventOfCode2019.CLI.main halts" do
    with_mock System, halt: fn code -> code end do
      with_mock IO, puts: fn _data -> :ok end do
        assert AdventOfCode2019.CLI.main([]) == 1
        assert_called(IO.puts(:_))
      end
    end
  end

  test "AdventOfCode2019.CLI.main runs stream_lines" do
    with_mock AdventOfCode2019,
      stream_lines: fn _in_stream, _day_part -> :ok end do
      with_mock IO,
        puts: fn data -> data end,
        stream: fn _stdio, _line -> ["much", "lines"] end do
        assert AdventOfCode2019.CLI.main(["1", "2"]) == :ok
        assert_called(IO.stream(:stdio, :line))
        assert_called(IO.puts(:ok))
        assert_called(AdventOfCode2019.stream_lines(["much", "lines"], "1.2"))
      end
    end
  end
end
