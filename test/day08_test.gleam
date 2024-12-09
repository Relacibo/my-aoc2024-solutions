import day08.{day_number_string, read_input, solution1, solution2}
import startest.{describe, it}
import startest/expect

pub fn day08_tests() {
  let assert Ok(input) =
    read_input("resources/" <> day_number_string <> "/test_input.txt")
  describe(day_number_string, [
    it("solution 1", fn() {
      solution1(input)
      |> expect.to_equal(14)
    }),
    it("solution 2", fn() {
      solution2(input)
      |> expect.to_equal(34)
    }),
  ])
}
