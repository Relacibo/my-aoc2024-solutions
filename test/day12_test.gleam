import bool_grid.{BoolGrid}
import coords.{Coords}
import day12.{day_number_string, read_input, solution1, solution2}
import gleam/io
import startest.{describe, it}
import startest/expect

pub fn day12_tests() {
  let assert Ok(input) =
    read_input("resources/" <> day_number_string <> "/test_input.txt")
  describe(day_number_string, [
    //   it("array", fn() {
    //   bool_grid.new(2, 2)
    //   |> io.debug
    //   |> bool_grid.set_tile(Coords(1, 1), True)
    //   |> expect.to_equal(Ok(BoolGrid(<<0:8, 0:8, 0:8, 1:8>>, 2, 2)))
    // }),
    // it("array", fn() {
    //   bool_grid.new(2, 2)
    //   |> io.debug
    //   |> bool_grid.set_tile(Coords(1, 0), True)
    //   |> expect.to_equal(Ok(BoolGrid(<<0:8, 1:8, 0:8, 0:8>>, 2, 2)))
    // }),
    // it("array", fn() {
    //   bool_grid.new(2, 2)
    //   |> io.debug
    //   |> bool_grid.set_tile(Coords(0, 1), True)
    //   |> expect.to_equal(Ok(BoolGrid(<<0:8, 0:8, 1:8, 0:8>>, 2, 2)))
    // }),
    it("solution 1", fn() {
      solution1(input)
      |> expect.to_equal(1930)
    }),
    it("solution 2", fn() {
      solution2(input)
      |> expect.to_equal(1206)
    }),
  ])
}
