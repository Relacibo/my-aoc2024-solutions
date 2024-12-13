import bool_grid.{type BoolGrid, BoolGrid}
import char_grid.{type CharGrid, CharGrid}
import coords.{type Coords, Coords}
import dict_util
import direction.{type Direction, East, North, South, West}
import gleam/bool
import gleam/dict
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
  calc_fence_price(grid, bool_grid.new(width, height), 0)
}

fn calc_fence_price(input: CharGrid, visited: BoolGrid, acc: Int) -> Int {
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
      calc_fence_price(input, visited, acc + borders_count * { v |> set.size })
    }
    Error(_) -> acc
  }
}

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

  let #(next_coords, border) =
    next_coords
    |> list.partition(is_in_region(input, region_char, _))
  let border_count = border_count + { border |> list.length }
  let next_coords =
    next_coords |> list.filter(fn(c) { !set.contains(visited, c) })
  let visited = visited |> set.union(next_coords |> set.from_list)

  let acc = ScanRegion(visited, border_count)

  next_coords
  |> list.fold(acc, fn(acc, c) { scan_region(input, region_char, c, acc) })
}

pub fn solution2(input: Input) -> Int {
  let Input(grid) = input
  let CharGrid(_, width, height) = grid
  calc_reduced_fence_price(grid, bool_grid.new(width, height), 0)
}

fn calc_reduced_fence_price(input: CharGrid, visited: BoolGrid, acc: Int) -> Int {
  let starting_coords = visited |> bool_grid.search(fn(val) { !val })
  case starting_coords {
    Ok(coords) -> {
      let region_char = input |> char_grid.get_tile_unchecked(coords)
      let shape =
        find_region_tiles(
          input,
          region_char,
          coords,
          set.new() |> set.insert(coords),
        )
      let visited =
        shape
        |> set.fold(visited, fn(vis, val) {
          case vis |> bool_grid.set_tile(val, True) {
            Ok(g) -> g
            _ -> panic as "Out of bounds coords in visited set!"
          }
        })
      let number_of_sides =
        find_number_of_sides(input, region_char, shape |> set.to_list)
      calc_reduced_fence_price(
        input,
        visited,
        acc + number_of_sides * { shape |> set.size },
      )
    }
    Error(_) -> acc
  }
}

fn find_region_tiles(
  input: CharGrid,
  region_char: String,
  coords: Coords,
  visited: Set(Coords),
) -> Set(Coords) {
  let next_coords =
    direction.iter_non_diag()
    |> list.map(fn(d) { coords |> coords.move_in_direction(d) })

  let next_coords =
    next_coords
    |> list.filter(is_in_region(input, region_char, _))
  let next_coords =
    next_coords |> list.filter(fn(c) { !set.contains(visited, c) })
  let visited = visited |> set.union(next_coords |> set.from_list)

  next_coords
  |> list.fold(visited, fn(acc, c) {
    find_region_tiles(input, region_char, c, acc)
  })
}

pub fn find_number_of_sides(
  input: CharGrid,
  region_char: String,
  shape: List(Coords),
) -> Int {
  let borders =
    shape
    |> list.map(fn(tile) {
      direction.iter_non_diag()
      |> list.flat_map(fn(d) {
        tile
        |> coords.move_in_direction(d)
        |> fn(coords) {
          !is_in_region(input, region_char, coords)
          |> bool.guard([#(d, [tile])], list.new)
        }
      })
      |> dict.from_list
    })
    |> dict_util.merge_all

  borders
  |> dict.to_list
  |> list.map(fn(t) {
    let #(direction, coords) = t
    coords
    |> list.map(get_level_and_value_for_direction(_, direction))
    |> find_number_of_sides_for_direction(0)
  })
  |> int.sum
}

fn get_level_and_value_for_direction(
  coords: Coords,
  direction: Direction,
) -> #(Int, Int) {
  let Coords(x, y) = coords
  case direction {
    North | South -> #(y, x)
    East | West -> #(x, y)
    _ -> panic as "Direction not supported"
  }
}

pub fn find_number_of_sides_for_direction(
  tiles: List(#(Int, Int)),
  acc: Int,
) -> Int {
  case tiles {
    [] -> acc
    [_] -> acc + 1
    [x, ..] -> {
      let #(tiles, tiles_next) =
        tiles
        |> list.partition(fn(other) { x.0 == other.0 })
      let sum =
        tiles
        |> list.map(fn(x) { x.1 })
        |> list.sort(int.compare)
        |> list.window(2)
        |> list.filter(fn(v) { v |> list.reduce(int.subtract) != Ok(-1) })
        |> list.length
      tiles_next
      |> find_number_of_sides_for_direction(acc + sum + 1)
    }
  }
}

pub type Input {
  Input(grid: CharGrid)
}

pub fn read_input(path: String) -> Result(Input, String) {
  use grid <- result.try(char_grid.read_from_path(path))
  Ok(Input(grid))
}

pub fn is_in_region(
  input: CharGrid,
  region_char: String,
  coords: Coords,
) -> Bool {
  case char_grid.get_tile(input, coords) {
    Ok(ch) if ch == region_char -> True
    _ -> False
  }
}
