import char_grid.{type CharGrid, CharGrid}
import coords.{type Coords}
import direction.{type Direction}
import gleam/bool
import gleam/deque.{type Deque}
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/queue
import gleam/result
import gleam/set.{type Set}
import gleam/string

const print_debug_output = False

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
  solution2(input, fn(x) { x >= 100 })
  |> int.to_string
  |> string.append("Problem 2 - Solution: ", _)
  |> io.println()
  Ok(Nil)
}

pub fn solution1(input: Input, threshold: Int) -> Int {
  let Input(race_track) = input
  let start =
    race_track
    |> char_grid.position(fn(c) { c == "S" })
    |> result.lazy_unwrap(fn() { panic as "No start found" })
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
  let #(d, c) =
    [".", "E"]
    |> list.filter_map(dict.get(surrounding, _))
    |> list.flatten
    |> list.first()
    |> result.lazy_unwrap(fn() { panic as "branch detected in race track" })

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

pub fn solution2(input: Input, condition: fn(Int) -> Bool) -> Int {
  let Input(race_track) = input
  let start =
    race_track
    |> char_grid.position(fn(c) { c == "E" })
    |> result.lazy_unwrap(fn() { panic as "No start found" })
  scan_path2(race_track, condition, start, None, 0, 0, dict.new())
}

pub fn scan_path2(
  race_track: CharGrid,
  condition: fn(Int) -> Bool,
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
    + {
      find_cheats(
        race_track,
        visited,
        step_counter,
        condition,
        [coords] |> set.from_list,
        [Pivot(0, coords)] |> deque.from_list,
        set.new(),
      )
      |> fn(l) {
        use <- bool.guard(!print_debug_output, l)
        let assert Ok(rt) = race_track |> char_grid.set_tile(coords, "O")
        l
        |> set.map(fn(c) {
          let assert Ok(rt) = rt |> char_grid.set_tile(c, "X")
          io.println(rt |> char_grid.to_string)
          io.println("")
        })
        l
      }
      |> set.size
    }

  use <- bool.guard(
    race_track |> char_grid.get_tile_unchecked(coords) == "S",
    cheat_counter,
  )
  let #(d, c) =
    [".", "S"]
    |> list.filter_map(dict.get(surrounding, _))
    |> list.flatten
    |> list.first
    |> result.lazy_unwrap(fn() { panic as "Path ended before finish" })

  scan_path2(
    race_track,
    condition,
    c,
    Some(d),
    step_counter + 1,
    cheat_counter,
    visited |> dict.insert(coords, step_counter),
  )
}

pub type Pivot {
  Pivot(cheat_step_counter: Int, coords: Coords)
}

pub fn find_cheats(
  race_track: CharGrid,
  previous_steps: Dict(Coords, Int),
  step_counter: Int,
  condition: fn(Int) -> Bool,
  visited: Set(Coords),
  queue: Deque(Pivot),
  acc: Set(Coords),
) -> Set(Coords) {
  let front = queue |> deque.pop_front
  use <- bool.guard(front |> result.is_error, acc)
  let assert Ok(#(Pivot(cheat_step_counter, coords), queue)) = front

  let surrounding =
    direction.iter_non_diag()
    |> list.map(coords.move_in_direction(coords, _))
    |> list.filter(fn(c) { !set.contains(visited, c) })

  let surrounding_grouped =
    surrounding
    |> list.group(fn(c) {
      race_track
      |> char_grid.get_tile(c)
      |> result.unwrap("?")
    })

  let cheat_coords =
    [".", "E"]
    |> list.filter_map(dict.get(surrounding_grouped, _))
    |> list.flatten
    |> list.filter(fn(c) {
      case previous_steps |> dict.get(c) {
        Ok(prev_step_counter) -> {
          let saved_time =
            step_counter - prev_step_counter - cheat_step_counter - 1
          condition(saved_time)
        }
        Error(_) -> {
          False
        }
      }
    })

  let visited =
    visited
    |> set.union(surrounding |> set.from_list)
  let acc = acc |> set.union(cheat_coords |> set.from_list)
  let queue = case
    cheat_step_counter < 19,
    [".", "E", "S", "#"]
    |> list.filter_map(dict.get(surrounding_grouped, _))
    |> list.flatten
  {
    False, _ | _, [] -> queue
    _, walls ->
      walls
      |> list.fold(queue, fn(queue, c) {
        queue |> deque.push_back(Pivot(cheat_step_counter + 1, c))
      })
  }
  find_cheats(
    race_track,
    previous_steps,
    step_counter,
    condition,
    visited,
    queue,
    acc,
  )
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
