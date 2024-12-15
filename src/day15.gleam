import char_grid.{type CharGrid, CharGrid}
import coords.{type Coords, Coords}
import direction.{type Direction, East, North, South, West}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/regexp
import gleam/result
import gleam/string
import simplifile

const print_debug_output = False

pub const day_number_string = "day15"

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
  let Input(room, moves) = input
  let assert Ok(robot_pos) = room |> char_grid.find(fn(c) { c == "@" })
  let assert Ok(room) = room |> char_grid.set_tile(robot_pos, ".")

  let #(room, _) =
    moves
    |> list.fold(#(room, robot_pos), fn(acc, dir) {
      let #(room, robot_pos) = acc
      let #(debug_room, debug_coords) as moved =
        try_move_robot(room, robot_pos, dir)
      case print_debug_output {
        True -> {
          print_state(debug_room, debug_coords, dir)
          Nil
        }
        _ -> Nil
      }
      moved
    })
  room
  |> char_grid.coords_fold(0, fn(acc, c, coords) {
    case c {
      "O" -> acc + { coords.y * 100 } + coords.x
      _ -> acc
    }
  })
}

pub fn print_state(room: CharGrid, coords: Coords, direction: Direction) {
  let robot_char = case direction {
    North -> "^"
    East -> ">"
    South -> "v"
    West -> "<"
    _ -> "?"
  }
  let assert Ok(room) = room |> char_grid.set_tile(coords, robot_char)
  io.println(room |> char_grid.to_string)
  io.println("")
}

pub fn try_move_robot(
  room: CharGrid,
  robot_pos: Coords,
  direction: Direction,
) -> #(CharGrid, Coords) {
  case find_next_non_box(room, robot_pos, direction) {
    #(_, "#") -> #(room, robot_pos)
    #(coords, ".") -> {
      let next_coords = robot_pos |> coords.move_in_direction(direction)
      let assert Ok(room) = room |> char_grid.set_tile(coords, "O")
      let assert Ok(room) = room |> char_grid.set_tile(next_coords, ".")
      #(room, next_coords)
    }
    _ -> panic as "unexpected tile"
  }
}

pub fn find_next_non_box(
  room: CharGrid,
  start: Coords,
  direction: Direction,
) -> #(Coords, String) {
  let next_coords = start |> coords.move_in_direction(direction)
  let assert Ok(next) = room |> char_grid.get_tile(next_coords)
  case next {
    "O" -> find_next_non_box(room, next_coords, direction)
    _ -> #(next_coords, next)
  }
}

pub fn solution2(input: Input) -> Int {
  let Input(room, moves) = input
  let room = widen_room(room)
  case print_debug_output {
    True -> {
      io.println(room |> char_grid.to_string)
      io.println("")
      Nil
    }
    _ -> Nil
  }
  let assert Ok(robot_pos) = room |> char_grid.find(fn(c) { c == "@" })
  let assert Ok(room) = room |> char_grid.set_tile(robot_pos, ".")
  let #(room, _) =
    moves
    |> list.fold(#(room, robot_pos), fn(acc, dir) {
      let #(room, robot_pos) = acc
      let #(room, robot_pos) as moved = case
        try_move_robot_wide(room, robot_pos, dir)
      {
        Ok(new_room) -> {
          let assert Ok(new_room) =
            new_room |> char_grid.set_tile(robot_pos, ".")
          let robot_pos = robot_pos |> coords.move_in_direction(dir)
          #(new_room, robot_pos)
        }
        Error(_) -> #(room, robot_pos)
      }
      case print_debug_output {
        True -> {
          print_state(room, robot_pos, dir)
          Nil
        }
        _ -> Nil
      }
      moved
    })
  room
  |> char_grid.coords_fold(0, fn(acc, c, coords) {
    case c {
      "[" -> acc + { coords.y * 100 } + coords.x
      _ -> acc
    }
  })
}

pub fn try_move_robot_wide(
  room: CharGrid,
  coords: Coords,
  direction: Direction,
) -> Result(CharGrid, Nil) {
  case direction {
    East | West -> {
      let next_coords = coords |> coords.move_in_direction(direction)
      let assert Ok(next_tile) = room |> char_grid.get_tile(next_coords)
      case next_tile {
        "." -> Ok(room)
        "#" -> Error(Nil)
        _ -> {
          let next_coords2 = next_coords |> coords.move_in_direction(direction)
          try_move_robot_wide(room, next_coords2, direction)
          |> result.map(fn(room) {
            let assert Ok(next_tile2) = room |> char_grid.get_tile(next_coords2)
            let target_coords =
              next_coords2 |> coords.move_in_direction(direction)
            let assert Ok(room) =
              room |> char_grid.set_tile(target_coords, next_tile2)
            let assert Ok(room) =
              room |> char_grid.set_tile(next_coords2, next_tile)
            room
          })
        }
      }
    }
    North | South -> {
      let next_coords = coords |> coords.move_in_direction(direction)
      let assert Ok(next_tile) = room |> char_grid.get_tile(next_coords)
      case next_tile {
        "." -> Ok(room)
        "#" -> Error(Nil)
        _ -> {
          let d = case next_tile {
            "[" -> 1
            "]" -> -1
            _ -> panic as "Tile not expected"
          }
          let next_coords2 = next_coords |> coords.add(Coords(d, 0))
          use room <- result.try(try_move_robot_wide(
            room,
            next_coords,
            direction,
          ))
          use room <- result.try(try_move_robot_wide(
            room,
            next_coords2,
            direction,
          ))
          let next_coords_target =
            next_coords |> coords.move_in_direction(direction)
          let next_coords2_target =
            next_coords2 |> coords.move_in_direction(direction)
          let assert Ok(next_tile2) = room |> char_grid.get_tile(next_coords2)
          let assert Ok(room) = room |> char_grid.set_tile(next_coords, ".")
          let assert Ok(room) = room |> char_grid.set_tile(next_coords2, ".")
          let assert Ok(room) =
            room |> char_grid.set_tile(next_coords_target, next_tile)
          let assert Ok(room) =
            room |> char_grid.set_tile(next_coords2_target, next_tile2)
          Ok(room)
        }
      }
    }
    _ -> panic as "Direction not supported"
  }
}

pub fn widen_room(room: CharGrid) -> CharGrid {
  let CharGrid(_, width, heigth) = room
  let new_room = char_grid.new(width * 2, heigth, ".")
  room
  |> char_grid.coords_fold(new_room, fn(new_room, c, coords) {
    let Coords(x, y) = coords
    let new_coords_left = Coords(x * 2, y)
    let new_coords_right = new_coords_left |> coords.add(Coords(1, 0))
    let #(new_char_left, new_char_right) = case c {
      "@" -> #("@", ".")
      "O" -> #("[", "]")
      "#" -> #("#", "#")
      "." -> #(".", ".")
      _ -> panic as "Unexpected char"
    }
    let assert Ok(new_room) =
      new_room |> char_grid.set_tile(new_coords_left, new_char_left)
    let assert Ok(new_room) =
      new_room |> char_grid.set_tile(new_coords_right, new_char_right)
    new_room
  })
}

pub type Input {
  Input(room: CharGrid, moves: List(Direction))
}

pub fn read_input(path: String) -> Result(Input, String) {
  use content <- result.try(
    simplifile.read(path)
    |> result.map_error(fn(_) { "Could not read file" }),
  )

  let #(room_input, moves_input) =
    content
    |> string.split("\n")
    |> list.split_while(fn(s) { !string.is_empty(s) })

  let assert Ok(room) =
    room_input
    |> char_grid.from_lines

  let moves =
    moves_input
    |> string.concat
    |> string.to_graphemes
    |> list.filter_map(fn(c) {
      case c {
        "^" -> Ok(North)
        ">" -> Ok(East)
        "v" -> Ok(South)
        "<" -> Ok(West)
        _ -> Error(Nil)
      }
    })

  Input(room, moves) |> Ok
}
