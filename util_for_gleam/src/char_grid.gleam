import coords.{type Coords, Coords}
import gleam/bit_array
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub type CharGrid {
  CharGrid(content: BitArray, width: Int, height: Int)
}

pub fn is_in_bounds(input: CharGrid, coords: Coords) -> Bool {
  let CharGrid(_, width, height) = input
  let Coords(x, y) = coords
  x >= 0 && y >= 0 && x < width && y < height
}

pub fn get_tile(input: CharGrid, coords: Coords) -> Result(String, Nil) {
  let CharGrid(content, width, _) = input
  let Coords(x, y) = coords
  use ret <- result.try(case is_in_bounds(input, coords) {
    True -> {
      content |> bit_array.slice(y * width + x, 1)
    }
    False -> Error(Nil)
  })
  let assert Ok(ret) = ret |> bit_array.to_string
  Ok(ret)
}

pub fn get_tile_unchecked(input: CharGrid, coords: Coords) -> String {
  let CharGrid(content, width, _) = input
  let Coords(x, y) = coords
  let assert Ok(ret) = content |> bit_array.slice(y * width + x, 1)
  let assert Ok(ret) = ret |> bit_array.to_string
  ret
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
