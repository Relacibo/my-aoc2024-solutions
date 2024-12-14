import coords.{type Coords, Coords}
import gleam/dict
import gleam/function
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order.{Eq, Gt, Lt}
import gleam/regexp
import gleam/result
import gleam/string
import simplifile

pub const day_number_string = "day14"

pub fn main() {
  case run_solutions() {
    Error(err) -> io.println(err)
    _ -> Nil
  }
}

const board_width = 101

const board_height = 103

pub fn run_solutions() -> Result(Nil, String) {
  use input <- result.try(read_input(
    "resources/" <> day_number_string <> "/input.txt",
  ))
  solution1(input, board_width, board_height)
  |> int.to_string
  |> string.append("Problem 1 - Solution: ", _)
  |> io.println()
  solution2(input)
  |> int.to_string
  |> string.append("Problem 2 - Solution: ", _)
  |> io.println()
  Ok(Nil)
}

pub fn solution1(input: Input, width: Int, height: Int) -> Int {
  let Input(robots) = input
  robots
  |> list.map(move_robot(_, 100, width, height))
  |> calc_security_rating(width, height)
}

pub fn move_robot(robot: Robot, steps: Int, width: Int, height: Int) -> Robot {
  let Robot(Coords(x, y), Coords(v_x, v_y) as v) = robot
  let x_new = { x + v_x * steps } |> int.modulo(width) |> result.unwrap(1000)
  let y_new = { y + v_y * steps } |> int.modulo(height) |> result.unwrap(1000)
  Robot(Coords(x_new, y_new), v)
}

pub fn calc_security_rating(robots: List(Robot), width: Int, height: Int) -> Int {
  robots
  |> list.filter_map(get_robot_quadrant(_, width, height))
  |> list.group(function.identity)
  |> dict.values()
  |> list.map(list.length)
  |> int.product
}

pub fn get_robot_quadrant(
  robot: Robot,
  width: Int,
  height: Int,
) -> Result(Int, Nil) {
  let Robot(Coords(x, y), ..) = robot
  case int.compare(x, width / 2), int.compare(y, height / 2) {
    Lt, Lt -> Ok(0)
    Gt, Lt -> Ok(1)
    Lt, Gt -> Ok(2)
    Gt, Gt -> Ok(3)
    _, _ -> Error(Nil)
  }
}

pub fn solution2(input: Input) -> Int {
  todo
}

pub type Input {
  Input(List(Robot))
}

pub type Robot {
  Robot(pos: Coords, v: Coords)
}

pub fn read_input(path: String) -> Result(Input, String) {
  use content <- result.try(
    simplifile.read(path)
    |> result.map_error(fn(_) { "Could not read file" }),
  )
  let options = regexp.Options(case_insensitive: False, multi_line: True)
  let assert Ok(regex) =
    regexp.compile("^p=(\\d+),(\\d+) v=(-?\\d+),(-?\\d+)$", options)
  regex
  |> regexp.scan(content)
  |> list.map(fn(m) {
    let sm =
      m.submatches
      |> list.map(fn(n) {
        let assert Some(n) = n
        let assert Ok(i) = int.parse(n)
        i
      })
    let assert [x, y, v_x, v_y] = sm
    Robot(Coords(x, y), Coords(v_x, v_y))
  })
  |> Input
  |> Ok
}
