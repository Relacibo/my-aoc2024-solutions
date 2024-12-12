import coords.{type Coords, Coords}
import gleam/bit_array
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub type IntGrid {
  IntGrid(content: BitArray, width: Int, height: Int)
}

pub fn is_in_bounds(input: IntGrid, coords: Coords) -> Bool {
  let IntGrid(_, width, height) = input
  let Coords(x, y) = coords
  x >= 0 && y >= 0 && x < width && y < height
}

pub fn get_tile(input: IntGrid, coords: Coords) -> Result(BitArray, Nil) {
  let IntGrid(content, width, _) = input
  let Coords(x, y) = coords
  case is_in_bounds(input, coords) {
    True -> {
      content |> bit_array.slice(y * width + x, 1)
    }
    False -> Error(Nil)
  }
}

pub fn get_tile_unchecked(input: IntGrid, coords: Coords) -> BitArray {
  let IntGrid(content, width, _) = input
  let Coords(x, y) = coords
  let assert Ok(ret) = content |> bit_array.slice(y * width + x, 1)
  ret
}

pub fn read_from_file(path: String) -> Result(IntGrid, String) {
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
  Ok(IntGrid(
    rows |> list.map(fn(i) { <<i:int>> }) |> bit_array.concat,
    width,
    height,
  ))
}
