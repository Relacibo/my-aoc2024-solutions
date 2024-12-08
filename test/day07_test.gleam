import day07
import gleam/result
import gleeunit/should

pub fn problem1_test() {
  let assert Ok(input) = day07.read_input("resources/day07/test_input.txt")
  day07.solution1(input)
  |> should.equal(3749)
}

pub fn problem2_test() {
  let assert Ok(input) = day07.read_input("resources/day07/test_input.txt")
  day07.solution2(input)
  |> should.equal(11_387)
}
