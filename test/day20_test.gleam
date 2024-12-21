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
    it("solution 2 - th: 77", fn() {
      solution2(input, fn(x) { x == 77 })
      |> expect.to_equal(0)
    }),
    it("solution 2 - th: 76", fn() {
      solution2(input, fn(x) { x == 76 })
      |> expect.to_equal(3)
    }),
    it("solution 2 - th: 74", fn() {
      solution2(input, fn(x) { x == 74 })
      |> expect.to_equal(4)
    }),
    it("solution 2 - th: 72", fn() {
      solution2(input, fn(x) { x == 72 })
      |> expect.to_equal(22)
    }),
    it("solution 2 - th: 70", fn() {
      solution2(input, fn(x) { x == 70 })
      |> expect.to_equal(12)
    }),
    it("solution 2 - th: 68", fn() {
      solution2(input, fn(x) { x == 68 })
      |> expect.to_equal(14)
    }),
    it("solution 2 - th: 66", fn() {
      solution2(input, fn(x) { x == 66 })
      |> expect.to_equal(12)
    }),
    it("solution 2 - th: 64", fn() {
      solution2(input, fn(x) { x == 64 })
      |> expect.to_equal(19)
    }),
    it("solution 2 - th: 62", fn() {
      solution2(input, fn(x) { x == 62 })
      |> expect.to_equal(20)
    }),
    it("solution 2 - th: 60", fn() {
      solution2(input, fn(x) { x == 60 })
      |> expect.to_equal(23)
    }),
    it("solution 2 - th: 58", fn() {
      solution2(input, fn(x) { x == 58 })
      |> expect.to_equal(25)
    }),
    it("solution 2 - th: 56", fn() {
      solution2(input, fn(x) { x == 56 })
      |> expect.to_equal(39)
    }),
    it("solution 2 - th: 54", fn() {
      solution2(input, fn(x) { x == 54 })
      |> expect.to_equal(29)
    }),
    it("solution 2 - th: 52", fn() {
      solution2(input, fn(x) { x == 52 })
      |> expect.to_equal(31)
    }),
    it("solution 2 - th: 50", fn() {
      solution2(input, fn(x) { x == 50 })
      |> expect.to_equal(32)
    }),
  ])
}
