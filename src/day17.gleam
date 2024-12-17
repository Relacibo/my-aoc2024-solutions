import gleam/bit_array
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/otp/task
import gleam/regexp
import gleam/result
import gleam/string
import simplifile

const print_debug_output = False

pub const day_number_string = "day17"

pub fn main() {
  case run_solutions() {
    Error(err) -> io.println(err)
    _ -> Nil
  }
}

pub fn run_solutions() -> Result(Nil, String) {
  use input <- result.try(read_input(
    "resources/" <> day_number_string <> "/input.txt",
  ))
  solution1(input)
  |> string.append("Problem 1 - Solution: ", _)
  |> io.println()
  solution2(input)
  |> int.to_string
  |> string.append("Problem 2 - Solution: ", _)
  |> io.println()
  Ok(Nil)
}

pub fn solution1(state: State) -> String {
  apply_all_remaining_ops(state)
  |> list.reverse
  |> list.map(int.to_string)
  |> list.intersperse(",")
  |> string.concat
}

pub fn apply_all_remaining_ops(state: State) -> List(Int) {
  case apply_op(state) {
    Ok(state) -> apply_all_remaining_ops(state)
    Error(_) -> {
      state.output
    }
  }
}

pub fn apply_op(state: State) -> Result(State, Nil) {
  let State(
    program,
    program_counter,
    register_a,
    register_b,
    register_c,
    output,
  ) = state
  use slice <- result.try(program |> bit_array.slice(program_counter, 2))
  let assert [op_code, literal_operand] =
    slice
    |> bit_array.to_string
    |> result.unwrap("0")
    |> string.to_utf_codepoints
    |> list.map(string.utf_codepoint_to_int)
  let combo_operand = case literal_operand {
    0 | 1 | 2 | 3 -> literal_operand
    4 -> register_a
    5 -> register_b
    6 -> register_c
    _ -> panic as "Invalid operand"
  }
  let program_counter_next = program_counter + 2
  let state = case op_code {
    0 -> {
      let register_a =
        register_a
        / {
          int.power(2, combo_operand |> int.to_float)
          |> result.unwrap(1.0)
          |> float.floor
          |> float.round
        }
      State(
        program,
        program_counter_next,
        register_a,
        register_b,
        register_c,
        output,
      )
    }
    1 -> {
      let register_b = int.bitwise_exclusive_or(register_b, literal_operand)
      State(
        program,
        program_counter_next,
        register_a,
        register_b,
        register_c,
        output,
      )
    }
    2 -> {
      let register_b = int.modulo(combo_operand, 8) |> result.unwrap(0)
      State(
        program,
        program_counter_next,
        register_a,
        register_b,
        register_c,
        output,
      )
    }
    3 -> {
      case register_a != 0 {
        True ->
          State(
            program,
            literal_operand,
            register_a,
            register_b,
            register_c,
            output,
          )
        False ->
          State(
            program,
            program_counter_next,
            register_a,
            register_b,
            register_c,
            output,
          )
      }
    }
    4 -> {
      let register_b = int.bitwise_exclusive_or(register_b, register_c)
      State(
        program,
        program_counter_next,
        register_a,
        register_b,
        register_c,
        output,
      )
    }
    5 -> {
      let out = int.modulo(combo_operand, 8) |> result.unwrap(0)
      State(program, program_counter_next, register_a, register_b, register_c, [
        out,
        ..output
      ])
    }
    6 -> {
      let register_b =
        register_a
        / {
          int.power(2, combo_operand |> int.to_float)
          |> result.unwrap(1.0)
          |> float.floor
          |> float.round
        }
      State(
        program,
        program_counter_next,
        register_a,
        register_b,
        register_c,
        output,
      )
    }
    7 -> {
      let register_c =
        register_a
        / {
          int.power(2, combo_operand |> int.to_float)
          |> result.unwrap(1.0)
          |> float.floor
          |> float.round
        }
      State(
        program,
        program_counter_next,
        register_a,
        register_b,
        register_c,
        output,
      )
    }
    _ -> panic as "op_code not supported"
  }
  Ok(state)
}

pub fn solution2(state: State) -> Int {
  let reversed_program =
    state.program
    |> bit_array.to_string
    |> result.unwrap("0")
    |> string.to_utf_codepoints
    |> list.map(fn(c) { string.utf_codepoint_to_int(c) })
    |> list.reverse

  let all_answers = guess_initial_a_incrementally(0, reversed_program)
  case print_debug_output {
    True -> {
      io.debug(all_answers)
      Nil
    }
    False -> Nil
  }
  all_answers
  |> list.reduce(int.min)
  |> result.unwrap(-1)
}

fn int_power(num1: Int, num2: Int) -> Int {
  int.power(num1, num2 |> int.to_float)
  |> result.unwrap(1.0)
  |> float.floor
  |> float.round
}

// bst a
// bxl 1
// cdv b
// bxl 5
// bxc
// adv 3
// out b
// jnz 0
pub fn run_program(state: State) -> List(Int) {
  let State(program, pc, a, _, _, out) = state

  // 2,4 -> bst a
  let b = a % 8

  // 1,1 -> bxl 1
  let b = int.bitwise_exclusive_or(b, 1)

  // 7,5 -> cdv b
  let c = a / int_power(2, b)

  // 1,5 -> bxl 5
  let b = int.bitwise_exclusive_or(b, 5)

  // 4,0 -> bxc
  let b = int.bitwise_exclusive_or(b, c)

  // 0,3 -> adv 3
  let a = a / 8

  // 5,5 -> out b
  let out = [b % 8, ..out]
  case a != 0 {
    True -> run_program(State(program, pc, a, b, c, out))
    False -> out
  }
}

pub fn guess_initial_a_incrementally(a_next: Int, out: List(Int)) -> List(Int) {
  case out {
    [] -> [a_next]
    [b_mod_8_next, ..out] -> {
      let a_candidate = a_next * 8
      let filtered_a_candidates =
        find_right_step(
          list.range(a_candidate, a_candidate + 7),
          b_mod_8_next,
          [],
        )
      filtered_a_candidates
      |> list.flat_map(guess_initial_a_incrementally(_, out))
    }
  }
}

pub fn find_right_step(
  a_candidates: List(Int),
  b_mod_8_next: Int,
  acc: List(Int),
) -> List(Int) {
  case a_candidates {
    [] -> acc
    [a, ..a_candidates] -> {
      let b =
        int.bitwise_exclusive_or(
          int.bitwise_exclusive_or(int.bitwise_exclusive_or(a % 8, 1), 5),
          a / int_power(2, int.bitwise_exclusive_or(a % 8, 1)),
        )

      let acc = case b % 8 == b_mod_8_next {
        True -> [a, ..acc]
        False -> acc
      }
      find_right_step(a_candidates, b_mod_8_next, acc)
    }
  }
}

pub fn read_input(path: String) -> Result(State, String) {
  use content <- result.try(
    simplifile.read(path)
    |> result.map_error(fn(_) { "Could not read file" }),
  )
  let assert [registers, program] = content |> string.split("\n\n")
  let options = regexp.Options(case_insensitive: False, multi_line: True)
  let assert Ok(regex) =
    regexp.compile(
      "^Register A: (\\d+)\nRegister B: (\\d+)\nRegister C: (\\d+)$",
      options,
    )
  let assert [match] =
    regex
    |> regexp.scan(registers)
  let assert [register_a, register_b, register_c] =
    match.submatches
    |> list.map(fn(n) {
      let assert Some(n) = n
      let assert Ok(i) = int.parse(n)
      i
    })
  let assert Ok(regex) = regexp.from_string("^Program: (.+)$")
  let assert [match] = regex |> regexp.scan(program)
  let assert [Some(submatch)] = match.submatches
  let program =
    submatch
    |> string.split(",")
    |> list.map(fn(n) {
      let assert Ok(i) = int.parse(n)
      i
    })

  let program =
    program
    |> list.map(fn(i) {
      let assert Ok(c) = string.utf_codepoint(i)
      c
    })
    |> string.from_utf_codepoints
    |> bit_array.from_string

  State(program, 0, register_a, register_b, register_c, [])
  |> Ok
}

pub type State {
  State(
    program: BitArray,
    program_counter: Int,
    register_a: Int,
    register_b: Int,
    register_c: Int,
    output: List(Int),
  )
}
