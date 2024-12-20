import char_grid.{type CharGrid, CharGrid}
import coords.{type Coords}
import direction.{type Direction}
import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string

pub const day_number_string = "day20"

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
  solution1(input, 100)
  |> int.to_string
  |> string.append("Problem 1 - Solution: ", _)
  |> io.println()
  solution2(input)
  |> int.to_string
  |> string.append("Problem 2 - Solution: ", _)
  |> io.println()
  Ok(Nil)
}

pub fn solution1(input: Input, threshold: Int) -> Int {
  let Input(race_track) = input
  let assert Ok(start) = race_track |> char_grid.position(fn(c) { c == "S" })
  scan_path(race_track, threshold, start, None, 0, 0, dict.new())
}

pub fn scan_path(
  race_track: CharGrid,
  threshold: Int,
  coords: Coords,
  entry_direction: Option(Direction),
  step_counter: Int,
  cheat_counter: Int,
  visited: Dict(Coords, Int),
) -> Int {
  let surrounding =
    direction.iter_non_diag()
    |> list.filter(fn(d) {
      Some(d) != { entry_direction |> option.map(direction.opposite) }
    })
    |> list.map(fn(d) { #(d, coords.move_in_direction(coords, d)) })
    |> list.group(fn(t) {
      let #(_, coords) = t
      race_track
      |> char_grid.get_tile_unchecked(coords)
    })

  let cheat_counter =
    cheat_counter
    + case surrounding |> dict.get("#") {
      Ok(cheat_candidates) ->
        cheat_candidates
        |> list.map(fn(t) {
          let #(d, coords) = t
          coords.move_in_direction(coords, d)
        })
        |> list.filter(fn(coords) {
          case visited |> dict.get(coords) {
            Ok(step_num) -> step_counter - step_num > threshold
            _ -> False
          }
        })
        |> list.length
      _ -> 0
    }
  use <- bool.guard(
    race_track |> char_grid.get_tile_unchecked(coords) == "E",
    cheat_counter,
  )
  let assert [#(d, c)] =
    surrounding
    |> dict.get(".")
    |> result.unwrap([])
    |> list.append(surrounding |> dict.get("E") |> result.unwrap([]))

  scan_path(
    race_track,
    threshold,
    c,
    Some(d),
    step_counter + 1,
    cheat_counter,
    visited |> dict.insert(coords, step_counter),
  )
}

pub fn solution2(input: Input) -> Int {
  todo
}

pub type Input {
  Input(race_track: CharGrid)
}

pub fn read_input(path: String) -> Result(Input, String) {
  path
  |> char_grid.read_from_path
  |> result.lazy_unwrap(fn() { panic as "Could not parse inputs" })
  |> Input
  |> Ok
}
