import day17.{
  type State, State, day_number_string, read_input, run_program, solution1,
}
import gleam/list
import startest.{describe, it}
import startest/expect

pub fn day17_tests() {
  let assert Ok(input) =
    read_input("resources/" <> day_number_string <> "/test_input.txt")
  let assert Ok(real_input) =
    read_input("resources/" <> day_number_string <> "/input.txt")
  let State(program, pc, a, b, c, out) = real_input
  describe(day_number_string, [
    it("solution 1", fn() {
      solution1(input)
      |> expect.to_equal("4,6,3,5,6,3,5,2,1,0")
    }),
    it("run_program_hard_coded", fn() {
      run_program(real_input)
      |> expect.to_equal([7, 2, 7, 5, 4, 0, 6, 4, 6])
    }),
    it("run_program_hard_coded2", fn() {
      run_program(State(program, pc, 164_541_160_582_845, b, c, out))
      |> expect.to_equal(
        [2, 4, 1, 1, 7, 5, 1, 5, 4, 0, 0, 3, 5, 5, 3, 0] |> list.reverse,
      )
    }),
  ])
}
