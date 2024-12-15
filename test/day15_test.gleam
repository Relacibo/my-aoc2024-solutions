import day15.{day_number_string, read_input, solution1, solution2}
import startest.{describe, it}
import startest/expect

pub fn day15_tests() {
  let assert Ok(input) =
    read_input("resources/" <> day_number_string <> "/test_input.txt")
  let assert Ok(input2) =
    read_input("resources/" <> day_number_string <> "/test_input2.txt")
  let assert Ok(custom_input) =
    read_input("resources/" <> day_number_string <> "/custom_test_input.txt")
  describe(day_number_string, [
    // it("solution 1 small", fn() {
  //   solution1(input2)
  //   |> expect.to_equal(2028)
  // }),
  // it("solution 1", fn() {
  //   solution1(input)
  //   |> expect.to_equal(10_092)
  // }),
  // it("solution 2", fn() {
  //   solution2(input)
  //   |> expect.to_equal(9021)
  // }),
  // it("solution custom", fn() {
  //   solution2(custom_input)
  //   |> expect.to_equal(10_569)
  // }),
  ])
}
