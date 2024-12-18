import char_grid.{type CharGrid, CharGrid}
import coords.{type Coords, Coords}
import direction.{type Direction, East, North, South, West}
import gleam/bool
import gleam/deque.{type Deque}
import gleam/int
import gleam/io
import gleam/list.{type ContinueOrStop, Continue, Stop}
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/set.{type Set}
import gleam/string
import simplifile

pub const day_number_string = "day18"

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
  solution1(input, 1024, 71, 71)
  |> int.to_string
  |> string.append("Problem 1 - Solution: ", _)
  |> io.println()
  solution2(input, 1024, 71, 71)
  |> string.append("Problem 2 - Solution: ", _)
  |> io.println()
  Ok(Nil)
}

pub fn solution1(
  input: Input,
  bytes_dropped: Int,
  width: Int,
  height: Int,
) -> Int {
  let Input(drops) = input
  let grid = char_grid.new(width, height, ".")
  let grid =
    drops
    |> list.take(bytes_dropped)
    |> list.fold(grid, fn(grid, drop) {
      let assert Ok(grid) = grid |> char_grid.set_tile(drop, "#")
      grid
    })
  let starting_coords = Coords(0, 0)
  let assert Ok(res) =
    solve_maze(
      grid,
      [Pivot(starting_coords, 0)] |> deque.from_list,
      [starting_coords] |> set.from_list,
    )
  res
}

pub type Pivot {
  Pivot(coords: Coords, steps: Int)
}

pub fn solve_maze(
  grid: CharGrid,
  queue: Deque(Pivot),
  visited: Set(Coords),
) -> Result(Int, Nil) {
  use #(Pivot(coords, steps), queue) <- result.try(queue |> deque.pop_front)
  let steps = steps + 1
  let new_coords =
    direction.iter_non_diag()
    |> list.filter_map(fn(d) {
      let c = coords.move_in_direction(coords, d)
      use <- bool.guard(set.contains(visited, c), Error(Nil))
      use tile <- result.try(char_grid.get_tile(grid, c))
      use <- bool.guard(tile == "#", Error(Nil))
      Ok(c)
    })

  case
    new_coords
    |> list.find(fn(c) { c == Coords(grid.width - 1, grid.height - 1) })
  {
    Ok(c) -> Ok(steps)
    _ -> {
      let queue =
        new_coords
        |> list.fold(queue, fn(queue, c) {
          queue |> deque.push_back(Pivot(c, steps))
        })
      let visited = visited |> set.union(new_coords |> set.from_list)
      solve_maze(grid, queue, visited)
    }
  }
}

pub fn solution2(
  input: Input,
  bytes_dropped: Int,
  width: Int,
  height: Int,
) -> String {
  let Input(drops) = input
  let grid = char_grid.new(width, height, ".")
  let grid =
    drops
    |> list.take(bytes_dropped)
    |> list.fold(grid, fn(grid, drop) {
      let assert Ok(grid) = grid |> char_grid.set_tile(drop, "#")
      grid
    })

  let new_drops = drops |> list.drop(bytes_dropped)
  let starting_coords = Coords(0, 0)

  let #(_, Coords(x, y)) =
    new_drops
    |> list.fold_until(#(grid, Coords(0, 0)), fn(acc, drop) {
      let #(grid, _) = acc
      let assert Ok(grid) = grid |> char_grid.set_tile(drop, "#")
      case
        solve_maze(
          grid,
          [Pivot(starting_coords, 0)] |> deque.from_list,
          [starting_coords] |> set.from_list,
        )
      {
        Error(_) -> Stop(#(grid, drop))
        Ok(_) -> Continue(#(grid, drop))
      }
    })
  [x, y] |> list.map(int.to_string) |> list.intersperse(",") |> string.concat
}

pub type Input {
  Input(drops: List(Coords))
}

pub fn read_input(path: String) -> Result(Input, String) {
  use content <- result.try(
    simplifile.read(path)
    |> result.map_error(fn(_) { "Could not read file" }),
  )

  content
  |> string.split("\n")
  |> list.filter(fn(s) { !string.is_empty(s) })
  |> list.map(fn(s) {
    let assert [x, y] =
      s
      |> string.split(",")
      |> list.map(fn(s) {
        let assert Ok(i) = s |> int.parse
        i
      })
    Coords(x, y)
  })
  |> Input
  |> Ok
}
