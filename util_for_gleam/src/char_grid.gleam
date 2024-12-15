import coords.{type Coords, Coords}
import gleam/bit_array
import gleam/bool
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub type CharGrid {
  CharGrid(content: BitArray, width: Int, height: Int)
}

pub fn new(width: Int, height: Int, init: String) -> CharGrid {
  let content =
    init
    |> bit_array.from_string
    |> list.repeat(width * height)
    |> bit_array.concat
  CharGrid(content, width, height)
}

pub fn is_in_bounds(input: CharGrid, coords: Coords) -> Bool {
  let CharGrid(_, width, height) = input
  let Coords(x, y) = coords
  x >= 0 && y >= 0 && x < width && y < height
}

pub fn set_tile(
  input: CharGrid,
  coords: Coords,
  val: String,
) -> Result(CharGrid, Nil) {
  let CharGrid(content, width, height) = input
  case is_in_bounds(input, coords) {
    True -> {
      let index = coords_to_internal_index(input, coords)
      use before <- result.try(bit_array.slice(content, 0, index))

      let val = val |> bit_array.from_string

      use <- bool.guard(val |> bit_array.byte_size != 1, Error(Nil))

      let content = case
        bit_array.slice(content, index + 1, height * width - index - 1)
      {
        Ok(after) -> <<before:bits, val:bits, after:bits>>
        Error(_) -> <<before:bits, val:bits>>
      }
      Ok(CharGrid(content, width, height))
    }
    False -> Error(Nil)
  }
}

pub fn get_tile(input: CharGrid, coords: Coords) -> Result(String, Nil) {
  let CharGrid(content, _, _) = input
  use ret <- result.try(case is_in_bounds(input, coords) {
    True -> {
      content |> bit_array.slice(coords_to_internal_index(input, coords), 1)
    }
    False -> Error(Nil)
  })
  let assert Ok(ret) = ret |> bit_array.to_string
  Ok(ret)
}

pub fn get_tile_unchecked(input: CharGrid, coords: Coords) -> String {
  input |> coords_to_internal_index(coords) |> get_tile_internal(input, _)
}

fn get_tile_internal(input: CharGrid, index: Int) -> String {
  let CharGrid(content, ..) = input
  let assert Ok(s) = bit_array.slice(content, index, 1)
  let assert Ok(s) = s |> bit_array.to_string
  s
}

fn internal_index_to_coords(input: CharGrid, index: Int) -> Coords {
  let CharGrid(_, width, _) = input
  Coords(index % width, index / width)
}

fn coords_to_internal_index(input: CharGrid, coords: Coords) -> Int {
  let CharGrid(_, width, _) = input
  let Coords(x, y) = coords
  y * width + x
}

pub fn find(grid: CharGrid, fun: fn(String) -> Bool) -> Result(Coords, Nil) {
  let CharGrid(_, width, height) = grid
  list.range(0, height * width - 1)
  |> list.find_map(fn(index) {
    case fun(get_tile_internal(grid, index)) {
      True -> Ok(internal_index_to_coords(grid, index))
      False -> Error(Nil)
    }
  })
}

pub fn coords_fold(grid: CharGrid, acc: a, fun: fn(a, String, Coords) -> a) -> a {
  let CharGrid(_, width, height) = grid
  list.range(0, height * width - 1)
  |> list.fold(acc, fn(acc, index) {
    fun(
      acc,
      get_tile_internal(grid, index),
      internal_index_to_coords(grid, index),
    )
  })
}

pub fn read_from_path(path: String) -> Result(CharGrid, String) {
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

  let content =
    rows
    |> list.map(string.to_graphemes)
    |> list.flatten
    |> string.concat
    |> bit_array.from_string

  Ok(CharGrid(content, width, height))
}

pub fn from_string(content: String) -> Result(CharGrid, String) {
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

  let content =
    rows
    |> list.map(string.to_graphemes)
    |> list.flatten
    |> string.concat
    |> bit_array.from_string

  Ok(CharGrid(content, width, height))
}

pub fn from_lines(rows: List(String)) -> Result(CharGrid, String) {
  let height =
    rows
    |> list.length

  use width <- result.try(
    list.first(rows)
    |> result.map(string.length)
    |> result.map_error(fn(_) { "Row empty!" }),
  )

  let content =
    rows
    |> list.map(string.to_graphemes)
    |> list.flatten
    |> string.concat
    |> bit_array.from_string

  Ok(CharGrid(content, width, height))
}

pub fn to_string(grid: CharGrid) -> String {
  let CharGrid(content, width, _) = grid
  content
  |> bit_array.to_string
  |> result.unwrap("")
  |> string.to_graphemes
  |> list.sized_chunk(width)
  |> list.intersperse(["\n"])
  |> list.flatten
  |> string.concat
}
