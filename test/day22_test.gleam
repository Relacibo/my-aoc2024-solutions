import day22.{day_number_string, read_input, solution1, solution2}
import startest.{describe, it}
import gleam/result
import startest/expect

pub fn day22_tests() {
  let input =
    read_input("resources/" <> day_number_string <> "/test_input.txt")
    |> result.lazy_unwrap(fn() { panic as "Could not read test input file" })
  describe(day_number_string, [
    it("solution 1", fn() {
      solution1(input)
      |> expect.to_equal(14)
    }),
    it("solution 2", fn() {
      solution2(input)
      |> expect.to_equal(14)
    }),
  ])
}
