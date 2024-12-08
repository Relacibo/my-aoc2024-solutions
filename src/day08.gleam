import gleam/bit_array
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
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

pub fn read_input(path: String) -> Result(Input, String) {
  use content <- result.try(
    simplifile.read(path)
    |> result.map_error(fn(_) { "Could not read file" }),
  )
  let content =
    content
    |> string.split("\n")
    |> list.filter(fn(s) { !string.is_empty(s) })
    |> list.index_map(fn(row, y) {
      row
      |> string.to_graphemes
      |> list.index_map(fn(g, x) {
        case g {
          "." -> []
          id -> [AntennaCoords(id, x, y)]
        }
      })
      |> list.flatten
    })
    |> list.flatten
  Ok(Input(content))
}

pub type Input {
  Input(coords: List(AntennaCoords))
}

pub type AntennaCoords {
  AntennaCoords(id: String, x: Int, y: Int)
}
