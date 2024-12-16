import char_grid.{type CharGrid, CharGrid}
import coords.{type Coords, Coords}
import direction.{type Direction, East, North, South, West}
import gleam/bool
import gleam/deque.{type Deque}
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/regexp
import gleam/result
import gleam/set.{type Set}
import gleam/string
import simplifile
import startest/test_case

pub const day_number_string = "day16"

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
  let Input(maze) = input
  let assert Ok(reindeer_start) = maze |> char_grid.position(fn(c) { c == "S" })
  solve(
    maze,
    [Pivot(reindeer_start, East, 0)] |> deque.from_list,
    [#(#(reindeer_start, East), 0)] |> dict.from_list,
    None,
  )
}

pub type Pivot {
  Pivot(position: Coords, direction: Direction, score: Int)
}

pub fn solve(
  maze: CharGrid,
  pivots: Deque(Pivot),
  visited: Dict(#(Coords, Direction), Int),
  minimum_score_candidate: Option(Int),
) -> Int {
  let res = pivots |> deque.pop_front
  let pivots = res |> result.map(fn(t) { t.1 }) |> result.unwrap(pivots)
  let pivot = res |> result.map(fn(t) { t.0 })
  case pivot {
    Error(_) -> {
      let assert Some(msc) = minimum_score_candidate
      msc
    }
    Ok(Pivot(position, direction, score)) -> {
      let new_pivots =
        [
          #(direction |> direction.next_counterclockwise_non_diag, score + 1001),
          #(direction, score + 1),
          #(direction |> direction.next_clockwise_non_diag, score + 1001),
        ]
        |> list.filter_map(fn(t) {
          let #(dir, sc) = t
          let coords = position |> coords.move_in_direction(dir)
          let assert Ok(tile) = maze |> char_grid.get_tile(coords)
          let is_more_expensive_than_candidate = case minimum_score_candidate {
            Some(msc) -> msc <= sc
            None -> False
          }
          use <- bool.guard(is_more_expensive_than_candidate, Error(Nil))

          let was_visited_cheaper = case visited |> dict.get(#(coords, dir)) {
            Ok(vs) -> vs <= sc
            _ -> False
          }
          use <- bool.guard(was_visited_cheaper, Error(Nil))
          case tile {
            "." | "E" -> Ok(#(Pivot(coords, dir, sc), tile))
            _ -> Error(Nil)
          }
        })
      let found_score =
        new_pivots
        |> list.find_map(fn(t) {
          let #(pivot, tile) = t
          case tile == "E" {
            True -> Ok(pivot.score)
            False -> Error(Nil)
          }
        })
      let new_pivots =
        new_pivots
        |> list.map(fn(t) { t.0 })
      let visited =
        new_pivots
        |> list.map(fn(p) {
          let Pivot(coords, dir, score) = p
          #(#(coords, dir), score)
        })
        |> dict.from_list
        |> dict.combine(visited, fn(e1, e2) { int.min(e1, e2) })
      let new_pivots =
        new_pivots
        |> list.fold(pivots, fn(pivots, p) { pivots |> deque.push_back(p) })
      let found =
        found_score
        |> option.from_result
        |> option.or(minimum_score_candidate)
      solve(maze, new_pivots, visited, found)
    }
  }
}

pub fn solution2(input: Input) -> Int {
  todo
}

pub type Input {
  Input(maze: CharGrid)
}

pub fn read_input(path: String) -> Result(Input, String) {
  use maze <- result.try(char_grid.read_from_path(path))
  Ok(Input(maze))
}
