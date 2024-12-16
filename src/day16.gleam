import char_grid.{type CharGrid, CharGrid}
import coords.{type Coords, Coords}
import direction.{type Direction, East}
import gleam/bool
import gleam/deque.{type Deque}
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order.{Eq, Gt, Lt}
import gleam/result
import gleam/set.{type Set}
import gleam/string

pub const day_number_string = "day16"

pub fn main() {
  case run_solutions() {
    Error(err) -> io.println(err)
    _ -> Nil
  }
}

const print_debug_output = False

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
  let Input(maze) = input
  let assert Ok(reindeer_start) = maze |> char_grid.position(fn(c) { c == "S" })
  solve2(
    maze,
    [#(Pivot(reindeer_start, East, 0), [reindeer_start])] |> deque.from_list,
    [#(#(reindeer_start, East), 0)] |> dict.from_list,
    None,
    [] |> set.from_list,
  )
  |> fn(s) {
    case print_debug_output {
      True -> {
        s
        |> set.fold(maze, fn(acc, c) {
          let assert Ok(acc) = acc |> char_grid.set_tile(c, "O")
          acc
        })
        |> char_grid.to_string
        |> io.println
        Nil
      }
      False -> {
        Nil
      }
    }

    s
  }
  |> set.size
}

pub fn solve2(
  maze: CharGrid,
  pivots: Deque(#(Pivot, List(Coords))),
  visited: Dict(#(Coords, Direction), Int),
  minimum_score_candidate: Option(Int),
  acc: Set(Coords),
) -> Set(Coords) {
  let res = pivots |> deque.pop_front
  let pivots = res |> result.map(fn(t) { t.1 }) |> result.unwrap(pivots)
  let pivot = res |> result.map(fn(t) { t.0 })
  case pivot {
    Error(_) -> {
      acc
    }
    Ok(#(Pivot(position, direction, score), path)) -> {
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
            Some(msc) -> msc < sc
            None -> False
          }
          use <- bool.guard(is_more_expensive_than_candidate, Error(Nil))

          let was_visited_cheaper = case visited |> dict.get(#(coords, dir)) {
            Ok(vs) -> vs < sc
            _ -> False
          }
          use <- bool.guard(was_visited_cheaper, Error(Nil))
          case tile {
            "." | "E" -> Ok(#(Pivot(coords, dir, sc), tile))
            _ -> Error(Nil)
          }
        })

      // Put everything in the visited set to avoid loops
      let visited =
        new_pivots
        |> list.map(fn(p) {
          let #(Pivot(coords, dir, score), _) = p
          #(#(coords, dir), score)
        })
        |> dict.from_list
        |> dict.combine(visited, fn(e1, e2) { int.min(e1, e2) })

      // Look for finish
      let #(found, new_pivots) =
        new_pivots
        |> list.partition(fn(t) {
          let #(_, tile) = t
          tile == "E"
        })

      // Only put elems on queue that are not the finish
      let found_pivot = case found {
        [] -> None
        [found] -> Some(found.0)
        _ -> panic as "Finish cannot be in 2 directions"
      }

      // Only put elems on queue that are not the finish
      let new_pivots =
        new_pivots
        |> list.map(fn(t) { t.0 })
        |> list.fold(pivots, fn(pivots, p) {
          let Pivot(coords, ..) = p
          pivots |> deque.push_back(#(p, [coords, ..path]))
        })

      let #(msc, acc) = case found_pivot, minimum_score_candidate {
        Some(found_pivot), Some(msc) -> {
          let Pivot(found_coords, _, found_score) = found_pivot
          case int.compare(found_score, msc) {
            Lt -> #(Some(found_score), [found_coords, ..path] |> set.from_list)
            Eq -> #(
              Some(msc),
              acc |> set.union([found_coords, ..path] |> set.from_list),
            )
            Gt -> #(Some(msc), acc)
          }
        }
        Some(found_pivot), _ -> {
          let Pivot(found_coords, _, found_score) = found_pivot
          #(Some(found_score), [found_coords, ..path] |> set.from_list)
        }
        _, _ -> {
          #(minimum_score_candidate, acc)
        }
      }
      solve2(maze, new_pivots, visited, msc, acc)
    }
  }
}

pub type Input {
  Input(maze: CharGrid)
}

pub fn read_input(path: String) -> Result(Input, String) {
  use maze <- result.try(char_grid.read_from_path(path))
  Ok(Input(maze))
}
