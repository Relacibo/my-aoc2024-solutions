import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/regexp
import gleam/result
import gleam/string
import simplifile

pub const day_number_string = "day19"

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
  let Input(towels, patterns) = input

  patterns |> list.filter_map(search_for_pattern(_, towels)) |> list.length
}

pub fn search_for_pattern(
  pattern: String,
  towels: List(String),
) -> Result(Nil, Nil) {
  use <- bool.guard(string.is_empty(pattern), Ok(Nil))
  towels
  |> list.filter_map(fn(towel) {
    use <- bool.guard(!string.starts_with(pattern, towel), Error(Nil))
    Ok(pattern |> string.drop_start(string.length(towel)))
  })
  |> list.find_map(search_for_pattern(_, towels))
}

pub fn solution2(input: Input) -> Int {
  todo
}

pub type Input {
  Input(towel_types: List(String), patterns: List(String))
}

pub fn read_input(path: String) -> Result(Input, String) {
  use content <- result.try(
    simplifile.read(path)
    |> result.map_error(fn(_) { "Could not read file" }),
  )
  let assert [towels, patterns] =
    content
    |> string.split("\n\n")
  let towels = towels |> string.split(", ")
  let patterns =
    patterns
    |> string.split("\n")
    |> list.filter(fn(s) { !string.is_empty(s) })
  Ok(Input(towels, patterns))
}
