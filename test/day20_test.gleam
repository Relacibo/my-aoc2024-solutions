import day20.{day_number_string, read_input, solution1, solution2}
import gleam/result
import startest.{describe, it}
import startest/expect

pub fn day20_tests() {
  let input =
    read_input("resources/" <> day_number_string <> "/test_input.txt")
    |> result.lazy_unwrap(fn() { panic as "Could not read test input file" })
  describe(day_number_string, [
    it("solution 1", fn() {
      solution1(input, 20)
      |> expect.to_equal(5)
    }),
    // it("solution 2 - th: 76", fn() {
    //   solution2(input, 76)
    //   |> expect.to_equal(3)
    // }),
    // it("solution 2 - th: 74", fn() {
    //   solution2(input, 74)
    //   |> expect.to_equal(7)
    // }),
    it("solution 2 - th: 72", fn() {
      solution2(input, 72)
      |> expect.to_equal(29)
    }),
    // it("solution 2 - th: 50", fn() {
  //   solution2(input, 50)
  //   |> expect.to_equal(282)
  // }),
  ])
}
