import day07
import startest/expect

pub fn problem1_test() {
  let assert Ok(input) = day07.read_input("resources/day07/test_input.txt")
  day07.solution1(input)
  |> expect.to_equal(3749)
}

pub fn problem2_test() {
  let assert Ok(input) = day07.read_input("resources/day07/test_input.txt")
  day07.solution2(input)
  |> expect.to_equal(11_387)
}
