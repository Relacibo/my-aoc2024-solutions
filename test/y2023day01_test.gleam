import startest.{describe, it}
import startest/expect
import y2023day01.{day_number_string, read_input, solution1, solution2}

pub fn y2023day01_tests() {
  let assert Ok(input) =
    read_input("resources/" <> day_number_string <> "/test_input.txt")
  let assert Ok(input2) =
    read_input("resources/" <> day_number_string <> "/test_input2.txt")
  describe(day_number_string, [
    it("solution 1", fn() {
      solution1(input)
      |> expect.to_equal(142)
    }),
    it("solution 2", fn() {
      solution2(input2)
      |> expect.to_equal(281)
    }),
  ])
}
