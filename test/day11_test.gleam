import day11.{
  cut_decimal_number_in_two, day_number_string, get_decimal_digit_count,
  read_input, solution1, solution2,
}
import startest.{describe, it}
import startest/expect

pub fn day08_tests() {
  let assert Ok(input) =
    read_input("resources/" <> day_number_string <> "/test_input.txt")
  describe(day_number_string, [
    it("solution 1", fn() {
      solution1(input)
      |> expect.to_equal(55_312)
    }),
    it("get_decimal_digit_count", fn() {
      get_decimal_digit_count(10)
      |> expect.to_equal(2)
    }),
    it("get_decimal_digit_count", fn() {
      get_decimal_digit_count(99_999_999_999)
      |> expect.to_equal(11)
    }),
    it("get_decimal_digit_count", fn() {
      get_decimal_digit_count(9_999_123_999_999)
      |> expect.to_equal(13)
    }),
    it("get_decimal_digit_count", fn() {
      get_decimal_digit_count(10_000_000_000_000)
      |> expect.to_equal(14)
    }),
    it("get_decimal_digit_count", fn() {
      get_decimal_digit_count(10_000_000_000_000)
      |> expect.to_equal(14)
    }),
    it("cut_decimal_number_in_two", fn() {
      cut_decimal_number_in_two(10_000_000_000_000, 14)
      |> expect.to_equal([1_000_000, 0])
    }),
  ])
}
