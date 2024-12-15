import day14.{day_number_string, read_input, solution1, solution2}
import startest.{describe, it}
import startest/expect

pub fn day14_tests() {
  let board_width = 11
  let board_height = 7
  let assert Ok(input) =
    read_input("resources/" <> day_number_string <> "/test_input.txt")
  describe(day_number_string, [
    it("solution 1", fn() {
      solution1(input, board_width, board_height)
      |> expect.to_equal(12)
    }),
  ])
}
