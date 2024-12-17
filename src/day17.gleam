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
  io.println("Problem 2 - Solution: ")
  solution2(input)
  Ok(Nil)
}

pub fn solution1(state: State) -> String {
  apply_all_remaining_ops(state)
  |> list.reverse
  |> list.map(int.to_string)
  |> list.intersperse(",")
  |> string.concat
}

pub fn solution2(state: State) {
  let State(
    program,
    program_counter,
    _register_a,
    register_b,
    register_c,
    output,
  ) = state
  let reversed_program =
    program
    |> bit_array.to_string
    |> result.unwrap("0")
    |> string.to_utf_codepoints
    |> list.map(fn(c) { string.utf_codepoint_to_int(c) })
    |> list.reverse
  list.range(0, 100_000_000)
  |> list.map(fn(register_a) {
    let state =
      State(
        program,
        program_counter,
        register_a,
        register_b,
        register_c,
        output,
      )
    find_async(state, reversed_program)
  })
  |> list.each(task.await_forever)
}

fn find_async(state: State, searched_output: List(Int)) {
  task.async(fn() {
    case apply_all_remaining_ops(state) == searched_output {
      True -> {
        io.println("Found: ")
        io.println(state.register_a |> int.to_string)
        Nil
      }
      False -> {
        Nil
      }
    }
  })
}

pub fn apply_all_remaining_ops(state: State) -> List(Int) {
  case apply_op(state) {
    Ok(state) -> apply_all_remaining_ops(state)
    Error(_) -> {
      state.output
    }
  }
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
