import coords.{type Coords, Coords}
import gleam/bit_array
import gleam/io
import gleam/list
import gleam/result

pub type BoolGrid {
  BoolGrid(content: BitArray, width: Int, height: Int)
}

pub fn new(width: Int, height: Int) -> BoolGrid {
  let content = <<0:8>> |> list.repeat(width * height) |> bit_array.concat
  BoolGrid(content, width, height)
}

pub fn search(grid: BoolGrid, fun: fn(Bool) -> Bool) -> Result(Coords, Nil) {
  let BoolGrid(_, width, height) = grid
  list.range(0, height * width - 1)
  |> list.find_map(fn(index) {
    case fun(get_tile_internal(grid, index)) {
      True -> Ok(internal_index_to_coords(grid, index))
      False -> Error(Nil)
    }
  })
}

pub fn coords_fold(grid: BoolGrid, acc: a, fun: fn(a, Bool, Coords) -> a) -> a {
  let BoolGrid(_, width, height) = grid
  list.range(0, height * width - 1)
  |> list.fold(acc, fn(acc, index) {
    fun(
      acc,
      get_tile_internal(grid, index),
      internal_index_to_coords(grid, index),
    )
  })
}

pub fn is_in_bounds(input: BoolGrid, coords: Coords) -> Bool {
  let BoolGrid(_, width, height) = input
  let Coords(x, y) = coords
  x >= 0 && y >= 0 && x < width && y < height
}

pub fn set_tile(
  input: BoolGrid,
  coords: Coords,
  val: Bool,
) -> Result(BoolGrid, Nil) {
  let BoolGrid(content, width, height) = input
  case is_in_bounds(input, coords) {
    True -> {
      let index = coords_to_internal_index(input, coords)
      let val = case val {
        True -> 1
        False -> 0
      }
      use before <- result.try(bit_array.slice(content, 0, index))

      let content = case
        bit_array.slice(content, index + 1, height * width - index - 1)
      {
        Ok(after) -> <<before:bits, <<val:8>>:bits, after:bits>>
        Error(_) -> <<before:bits, <<val:8>>:bits>>
      }
      Ok(BoolGrid(content, width, height))
    }
    False -> Error(Nil)
  }
}

pub fn get_tile(input: BoolGrid, coords: Coords) -> Result(Bool, Nil) {
  let BoolGrid(content, ..) = input

  case is_in_bounds(input, coords) {
    True ->
      case
        content |> bit_array.slice(coords_to_internal_index(input, coords), 1)
      {
        Ok(<<0>>) -> Ok(False)
        Ok(<<1>>) -> Ok(True)
        _ -> Error(Nil)
      }
    False -> Error(Nil)
  }
}

pub fn get_tile_unchecked(input: BoolGrid, coords: Coords) -> Bool {
  input |> coords_to_internal_index(coords) |> get_tile_internal(input, _)
}

fn get_tile_internal(input: BoolGrid, index: Int) -> Bool {
  let BoolGrid(content, ..) = input
  case content |> bit_array.slice(index, 1) {
    Ok(<<0>>) -> False
    Ok(<<1>>) -> True
    _ -> panic as "Unexpected: Out of bounds"
  }
}

fn internal_index_to_coords(input: BoolGrid, index: Int) -> Coords {
  let BoolGrid(_, width, _) = input
  Coords(index % width, index / width)
}

fn coords_to_internal_index(input: BoolGrid, coords: Coords) -> Int {
  let BoolGrid(_, width, _) = input
  let Coords(x, y) = coords
  y * width + x
}

pub fn to_string(input: BoolGrid) -> String {
  input
  |> coords_fold("", fn(acc, val, coords) {
    let p = case val {
      True -> "1"
      False -> "0"
    }
    case coords.x == input.width - 1 {
      True -> acc <> p <> "\n"
      False -> acc <> p
    }
  })
}
