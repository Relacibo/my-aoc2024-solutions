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
import gleam/list.{Continue, Stop}
import gleam/option.{type Option, None, Some}
import gleam/order.{type Order, Eq, Gt, Lt}
import gleam/regexp
import gleam/result
import gleam/set.{type Set}
import gleam/string
import simplifile

pub const day_number_string = "day24"

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
  todo
}

pub fn solution2(input: Input) -> Int {
  todo
}

pub type Input {
  Input
}

pub fn read_input(path: String) -> Result(Input, String) {
  use content <- result.try(
    simplifile.read(path)
    |> result.map_error(fn(_) { "Could not read file" }),
  )
  let assert [a, b] =
    content
    |> string.split("\n^\n")
    |> list.filter(fn(s) { !string.is_empty(s) })
  a |> string.split("\n") |> list.map(fn() { todo })
  let options = regexp.Options(case_insensitive: False, multi_line: True)
  let assert Ok(regex) = regexp.compile("^$", options)
  regex
  |> regexp.scan(content)
  |> list.map(fn(m) {
    let sm =
      m.submatches
      |> list.map(fn(n) {
        let assert Some(n) = n
        let assert Ok(i) = int.parse(n)
        i
      })
    todo
  })
  |> Input
  |> Ok
}
