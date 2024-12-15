import coords.{type Coords, Coords}
import gleam/bool
import gleam/dict
import gleam/erlang/process
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
  io.println("Problem 2 - Solution:")
  solution2(input, board_width, board_height)
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

pub fn solution2(input: Input, width: Int, height: Int) {
  let Input(robots) = input
  simulate_range(robots, 1, 7572, width, height)
}

pub fn simulate_range(
  robots: List(Robot),
  from: Int,
  to: Int,
  width: Int,
  height: Int,
) {
  let robots = case from > 1 {
    True -> move_robots(robots, from - 1, width, height)
    _ -> robots
  }
  list.range(from, to)
  |> list.fold(robots, fn(robots, i) {
    let robots = move_robots(robots, 1, width, height)
    use <- bool.guard(!should_show(robots, width), robots)
    io.print(i |> int.to_string)
    io.println(":")
    robots_debug_string(robots, width, height) |> io.println
    process.sleep(50)
    robots
  })
}

pub fn move_robots(
  robots: List(Robot),
  steps: Int,
  width: Int,
  height: Int,
) -> List(Robot) {
  robots |> list.map(move_robot(_, steps, width, height))
}

pub fn should_show(robots: List(Robot), width: Int) -> Bool {
  robots
  |> list.count(fn(r) { r.pos.x == 36 || r.pos.x == 66 })
  >= 65
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

pub fn robots_debug_string(
  robots: List(Robot),
  width: Int,
  height: Int,
) -> String {
  let robots =
    robots
    |> list.map(fn(r) { r.pos })
    |> list.group(fn(r) { r.y })
    |> dict.map_values(fn(_, l) {
      l |> list.sort(fn(r1, r2) { int.compare(r1.x, r2.x) })
    })
  list.range(0, height - 1)
  |> list.map(fn(y) {
    robots_debug_string_line(
      robots |> dict.get(y) |> result.unwrap([]),
      0,
      width,
      "",
    )
    <> "\n"
  })
  |> string.concat
}

pub fn robots_debug_string_line(
  robots: List(Coords),
  index: Int,
  width: Int,
  acc: String,
) -> String {
  case robots {
    [] -> acc <> string.repeat("\u{2B1B}", width - index)
    [Coords(x, _), ..xs] ->
      case x < index {
        True -> robots_debug_string_line(xs, index, width, acc)
        False ->
          robots_debug_string_line(
            xs,
            x + 1,
            width,
            acc <> string.repeat("\u{2B1B}", x - index) <> "\u{1F7E9}",
          )
      }
  }
}
