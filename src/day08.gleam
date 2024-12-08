import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub const day_number_string = "day08"

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
  |> string.append("Problem 1 - Solution: ", _)
  |> io.println()
  Ok(Nil)
}

pub type Input {
  Input
}

pub fn read_input(path: String) -> Result(Input, String) {
  use content <- result.try(
    simplifile.read(path)
    |> result.map_error(fn(_) { "Could not read file" }),
  )
  content
  |> string.split("\n")
  |> list.filter(fn(s) { !string.is_empty(s) })
  todo
}

pub fn solution1(input: Input) -> Int {
  todo
}

pub fn solution2(input: Input) -> Int {
  todo
}
