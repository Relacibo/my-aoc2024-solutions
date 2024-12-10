import gleam/bit_array
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import simplifile

pub const day_number_string = "day10"

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
  find_trail_heads(input)
  |> list.map(fn(c) { search(input, c, 0) |> set.size })
  |> int.sum
}

const directions: List(Coords) = [
  Coords(0, -1),
  Coords(1, 0),
  Coords(0, 1),
  Coords(-1, 0),
]

pub fn find_trail_heads(input: Input) -> List(Coords) {
  let Input(content, width, height) = input
  let len = width * height
  list.range(0, len - 1)
  |> list.map(fn(index) {
    let assert Ok(b) = bit_array.slice(content, index, 1)
    #(index, b)
  })
  |> list.flat_map(fn(t) {
    let #(index, b) = t
    case b == <<0:int>> {
      True -> [Coords(index % width, index / width)]
      False -> []
    }
  })
}

pub fn search(input: Input, coords: Coords, level: Int) -> Set(Coords) {
  case level == 9 {
    True -> set.new() |> set.insert(coords)
    False ->
      directions
      |> list.map(add_coords(coords, _))
      |> list.filter_map(fn(c) {
        get_tile(input, c)
        |> result.try(fn(b) {
          let level = level + 1
          case <<{ level }:int>> == b {
            True -> Ok(#(c, level))
            _ -> Error(Nil)
          }
        })
      })
      |> list.map(fn(t) {
        let #(coords, level) = t
        search(input, coords, level)
      })
      |> list.reduce(set.union)
      |> result.unwrap(set.new())
  }
}

pub fn solution2(input: Input) -> Int {
  find_trail_heads(input)
  |> list.map(fn(c) { search2(input, c, 0) })
  |> int.sum
}

pub fn search2(input: Input, coords: Coords, level: Int) -> Int {
  case level == 9 {
    True -> 1
    False ->
      directions
      |> list.map(add_coords(coords, _))
      |> list.filter_map(fn(c) {
        get_tile(input, c)
        |> result.try(fn(b) {
          let level = level + 1
          case <<{ level }:int>> == b {
            True -> Ok(#(c, level))
            _ -> Error(Nil)
          }
        })
      })
      |> list.map(fn(t) {
        let #(coords, level) = t
        search2(input, coords, level)
      })
      |> int.sum
  }
}

pub type Input {
  Input(content: BitArray, width: Int, height: Int)
}

fn get_tile(input: Input, coords: Coords) -> Result(BitArray, Nil) {
  let Input(content, width, _) = input
  let Coords(x, y) = coords
  case is_in_bounds(input, coords) {
    True -> {
      content |> bit_array.slice(y * width + x, 1)
    }
    False -> Error(Nil)
  }
}

fn get_tile_unchecked(input: Input, coords: Coords) -> BitArray {
  let Input(content, width, _) = input
  let Coords(x, y) = coords
  let assert Ok(ret) = content |> bit_array.slice(y * width + x, 1)
  ret
}

pub type Coords {
  Coords(x: Int, y: Int)
}

fn add_coords(a: Coords, b: Coords) -> Coords {
  let Coords(x1, y1) = a
  let Coords(x2, y2) = b
  Coords(x1 + x2, y1 + y2)
}

fn is_in_bounds(input: Input, coords: Coords) -> Bool {
  let Input(_, width, height) = input
  let Coords(x, y) = coords
  x >= 0 && y >= 0 && x < width && y < height
}

pub fn read_input(path: String) -> Result(Input, String) {
  use content <- result.try(
    simplifile.read(path)
    |> result.map_error(fn(_) { "Could not read file" }),
  )
  let rows =
    content
    |> string.split("\n")
    |> list.filter(fn(s) { !string.is_empty(s) })

  let height =
    rows
    |> list.length

  use width <- result.try(
    list.first(rows)
    |> result.map(string.length)
    |> result.map_error(fn(_) { "Row empty!" }),
  )
  use rows <- result.try(
    rows
    |> list.map(string.to_graphemes)
    |> list.flatten
    |> list.map(int.parse)
    |> result.all
    |> result.map_error(fn(_) { "Could not parse input!" }),
  )
  Ok(Input(
    rows |> list.map(fn(i) { <<i:int>> }) |> bit_array.concat,
    width,
    height,
  ))
}
