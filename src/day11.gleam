import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import gleam_community/maths/conversion
import gleam_community/maths/elementary
import simplifile

pub const day_number_string = "day11"

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
  |> int.to_string
  |> string.append("Problem 1 - Solution: ", _)
  |> io.println()
  solution2(input)
  |> int.to_string
  |> string.append("Problem 2 - Solution: ", _)
  |> io.println()
  Ok(Nil)
}

pub fn solution1(input: List(Int)) -> Int {
  input |> run_algorithm(25)
}

pub fn run_algorithm(list: List(Int), iterations_left: Int) -> Int {
  let iteration = iterations_left - 1
  case iteration >= 0 {
    True ->
      list
      |> list.flat_map(fn(num) {
        case num {
          0 -> [1]
          n -> {
            case get_decimal_digit_count(n) % 2 == 0 {
              True -> cut_decimal_number_in_two(n)
              False -> [n * 2024]
            }
          }
        }
      })
      |> run_algorithm(iteration)
    False -> list |> list.length
  }
}

pub fn get_decimal_digit_count(num: Int) -> Int {
  {
    num
    |> int.to_float
    |> elementary.logarithm_10
    |> result.unwrap(-1.0)
    |> conversion.float_to_int
  }
  + 1
}

fn cut_decimal_number_in_two(num: Int) -> List(Int) {
  let s = num |> int.to_string
  s
  |> string.to_graphemes
  |> list.sized_chunk({ s |> string.length } / 2)
  |> list.map(fn(s) { s |> string.concat |> int.parse |> result.unwrap(0) })
}

pub fn solution2(input: List(Int)) -> Int {
  input |> run_algorithm(75)
}

pub fn read_input(path: String) -> Result(List(Int), String) {
  use content <- result.try(
    simplifile.read(path)
    |> result.map_error(fn(_) { "Could not read file" }),
  )
  use line <- result.try(
    content
    |> string.split("\n")
    |> list.filter(fn(s) { !string.is_empty(s) })
    |> list.first()
    |> result.map_error(fn(_) { "No element in row!" }),
  )
  line
  |> string.split(" ")
  |> list.map(int.parse)
  |> result.all
  |> result.map_error(fn(_) { "Could not parse int!" })
}
