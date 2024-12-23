import char_grid.{type CharGrid, CharGrid}
import coords.{type Coords, Coords}
import dict_util
import direction.{type Direction, East, North, South, West}
import gleam/bool
import gleam/deque.{type Deque}
import gleam/dict.{type Dict}
import gleam/function
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order.{type Order, Eq, Gt, Lt}
import gleam/regexp
import gleam/result
import gleam/set.{type Set}
import gleam/string
import simplifile

pub const day_number_string = "day22"

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

pub fn solution1(input: Input) -> Int {
  let Input(starting_numbers) = input
  starting_numbers |> list.map(repeat(_, apply_ops, 2000)) |> int.sum
}

pub fn repeat(val: a, f: fn(a) -> a, times: Int) -> a {
  use <- bool.guard(times == 0, val)
  repeat(f(val), f, times - 1)
}

pub fn apply_ops(secret_number: Int) -> Int {
  let secret_number =
    int.bitwise_exclusive_or(secret_number, secret_number * 64) % 16_777_216
  let secret_number =
    int.bitwise_exclusive_or(secret_number, secret_number / 32) % 16_777_216
  int.bitwise_exclusive_or(secret_number, secret_number * 2048) % 16_777_216
}

pub fn solution2(input: Input) -> Int {
  todo
}

pub type Input {
  Input(starting_numbers: List(Int))
}

pub fn read_input(path: String) -> Result(Input, String) {
  use content <- result.try(
    simplifile.read(path)
    |> result.map_error(fn(_) { "Could not read file" }),
  )
  content
  |> string.split("\n")
  |> list.filter(fn(s) { !string.is_empty(s) })
  |> list.map(int.parse)
  |> result.all
  |> result.lazy_unwrap(fn() { panic as "Wrong input" })
  |> Input
  |> Ok
}
