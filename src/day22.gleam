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
  starting_numbers
  |> list.map(fn(x) {
    list.range(1, 2000) |> list.fold(x, fn(acc, _) { apply_ops(acc) })
  })
  |> int.sum
}

pub fn apply_ops(secret_number: Int) -> Int {
  let secret_number =
    int.bitwise_exclusive_or(secret_number, secret_number * 64) % 16_777_216
  let secret_number =
    int.bitwise_exclusive_or(secret_number, secret_number / 32) % 16_777_216
  int.bitwise_exclusive_or(secret_number, secret_number * 2048) % 16_777_216
}

pub fn solution2(input: Input) -> Int {
  let Input(starting_numbers) = input
  starting_numbers
  |> list.map(fn(x) {
    let prices =
      [
        x,
        ..list.range(1, 2000)
        |> list.scan(x, fn(acc, _) { apply_ops(acc) })
      ]
      |> list.map(fn(x) { x % 10 })
    prices
    |> list.window(5)
    |> list.map(fn(x) {
      x
      |> list.window_by_2()
      |> list.map(fn(x) { x.1 - x.0 })
    })
    |> list.zip(prices |> list.drop(4))
    |> list.reverse
    |> dict.from_list
  })
  |> list.reduce(fn(d1, d2) { dict.combine(d1, d2, fn(v1, v2) { v1 + v2 }) })
  |> result.lazy_unwrap(fn() { panic as "Expected dicts" })
  |> dict.values
  |> list.reduce(int.max)
  |> result.lazy_unwrap(fn() { panic as "No max value found" })
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
