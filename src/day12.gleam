import bool_grid.{type BoolGrid, BoolGrid}
import char_grid.{type CharGrid, CharGrid}
import coords.{type Coords, Coords}
import direction
import gleam/bit_array
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string

pub const day_number_string = "day12"

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
  let Input(grid) = input
  let CharGrid(_, width, height) = grid
  f(grid, bool_grid.new(width, height), 0)
}

fn f(input: CharGrid, visited: BoolGrid, acc: Int) -> Int {
  let starting_coords = visited |> bool_grid.search(fn(val) { !val })
  case starting_coords {
    Ok(coords) -> {
      let ScanRegion(v, borders_count) =
        scan_region(
          input,
          input |> char_grid.get_tile_unchecked(coords),
          coords,
          initialize_scan_region(coords),
        )
      let visited =
        v
        |> set.fold(visited, fn(vis, val) {
          case vis |> bool_grid.set_tile(val, True) {
            Ok(g) -> g
            _ -> panic as "Out of bounds coords in visited set!"
          }
        })
      f(input, visited, acc + borders_count * { v |> set.size })
    }
    Error(_) -> acc
  }
}

// pub fn get_number_of_sides(input: CharGrid, region_char: String, shape: List(Coords)) -> Int {
//   shape |> list.map(fn(){})
// }

type ScanRegion {
  ScanRegion(visited: Set(Coords), border_count: Int)
}

fn initialize_scan_region(coords: Coords) -> ScanRegion {
  ScanRegion(set.new() |> set.insert(coords), 0)
}

fn scan_region(
  input: CharGrid,
  region_char: String,
  coords: Coords,
  acc: ScanRegion,
) -> ScanRegion {
  let ScanRegion(visited, border_count) = acc
  let next_coords =
    direction.iter_non_diag()
    |> list.map(fn(d) { coords |> coords.move_in_direction(d) })

  let #(border, next_coords) =
    next_coords
    |> list.partition(fn(c) {
      !{ input |> char_grid.is_in_bounds(c) }
      || input
      |> char_grid.get_tile_unchecked(c)
      != region_char
    })
  let border_count = border_count + { border |> list.length }
  let next_coords =
    next_coords |> list.filter(fn(c) { !set.contains(visited, c) })
  let visited = visited |> set.union(next_coords |> set.from_list)

  let acc = ScanRegion(visited, border_count)

  next_coords
  |> list.fold(acc, fn(acc, c) { scan_region(input, region_char, c, acc) })
}

pub fn solution2(input: Input) -> Int {
  todo
}

pub type Input {
  Input(grid: CharGrid)
}

pub fn read_input(path: String) -> Result(Input, String) {
  use grid <- result.try(char_grid.read_from_path(path))
  Ok(Input(grid))
}
