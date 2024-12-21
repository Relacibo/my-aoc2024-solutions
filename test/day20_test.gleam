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
    // it("solution 2 - th: 78", fn() {
    //   solution2(input, fn(x) { x == 78 })
    //   |> expect.to_equal(0)
    // }),
    // it("solution 2 - th: 77", fn() {
    //   solution2(input, fn(x) { x == 77 })
    //   |> expect.to_equal(0)
    // }),
    // it("solution 2 - th: 76", fn() {
    //   solution2(input, fn(x) { x == 76 })
    //   |> expect.to_equal(3)
    // }),
    // it("solution 2 - th: 75", fn() {
    //   solution2(input, fn(x) { x == 75 })
    //   |> expect.to_equal(0)
    // }),
    it("solution 2 - th: 74", fn() {
      solution2(input, fn(x) { x >= 74 })
      |> expect.to_equal(7)
    }),
    // it("solution 2 - th: 72", fn() {
    //   solution2(input, fn(x) { x == 72 })
    //   |> expect.to_equal(22)
    // }),
    it("solution 2 - th: 70", fn() {
      solution2(input, fn(x) { x >= 70 })
      |> expect.to_equal(29)
    }),
    // it("solution 2 - th: 52", fn() {
    //   solution2(input, fn(x) { x == 52 })
    //   |> expect.to_equal(32)
    // }),
    // it("solution 2 - th: 51", fn() {
    //   solution2(input, fn(x) { x == 51 })
    //   |> expect.to_equal(0)
    // }),
    // it("solution 2 - th: 50", fn() {
    //   solution2(input, fn(x) { x == 50 })
    //   |> expect.to_equal(31)
    // }),
    it("solution 2", fn() {
      solution2(input, fn(x) { x >= 50 })
      |> expect.to_equal(282)
    }),
  ])
}
