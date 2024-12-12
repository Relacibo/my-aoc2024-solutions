import bool_grid.{BoolGrid}
import coords.{Coords}
import startest.{describe, it}
import startest/expect

pub fn bool_grid_tests() {
  describe("bool_grid", [
    it("set_first_row_end", fn() {
      bool_grid.new(3, 2)
      |> bool_grid.set_tile(Coords(2, 0), True)
      |> expect.to_equal(Ok(BoolGrid(<<0:8, 0:8, 1:8, 0:8, 0:8, 0:8>>, 3, 2)))
    }),
    it("set_last_row_start", fn() {
      bool_grid.new(3, 2)
      |> bool_grid.set_tile(Coords(0, 1), True)
      |> expect.to_equal(Ok(BoolGrid(<<0:8, 0:8, 0:8, 1:8, 0:8, 0:8>>, 3, 2)))
    }),
    it("set_end", fn() {
      bool_grid.new(3, 2)
      |> bool_grid.set_tile(Coords(2, 1), True)
      |> expect.to_equal(Ok(BoolGrid(<<0:8, 0:8, 0:8, 0:8, 0:8, 1:8>>, 3, 2)))
    }),
  ])
}
