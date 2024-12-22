import char_grid.{type CharGrid, CharGrid}
import coords.{type Coords, Coords}
import direction.{type Direction, East, North, South, West}
import gleam/bool
import gleam/deque.{type Deque}
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/regexp
import gleam/result
import gleam/set.{type Set}
import gleam/string
import simplifile

const print_debug_output = True

pub const day_number_string = "day21"

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
  let Input(combinations) = input
  let number_keyboard = create_number_keyboard()
  let direction_keyboard = create_direction_keyboard()
  combinations
  |> list.map(fn(comb) {
    let num1 =
      comb
      |> string.drop_end(1)
      |> int.parse
      |> result.lazy_unwrap(fn() { panic as "Could not parse int" })
    let num2 =
      comb
      |> string.to_graphemes
      |> use_keyboard(number_keyboard, [])
      |> use_keyboard(direction_keyboard, [])
      // |> use_keyboard(direction_keyboard, [])
      |> fn(x) {
        use <- bool.guard(!print_debug_output, x)
        io.debug(comb <> ": " <> string.concat(x))
        x
      }
      |> list.length
    num1 * num2
  })
  |> int.sum
}

pub fn use_keyboard(
  val: List(String),
  keyboard: Keyboard,
  acc: List(String),
) -> List(String) {
  case val {
    [] -> acc
    [l, ..ls] -> {
      let Keyboard(current_key, keys) = keyboard
      let node =
        keys
        |> dict.get(current_key)
        |> result.lazy_unwrap(fn() {
          panic as { "could not get node: " <> current_key }
        })
      let Node(_, other_nodes) = node
      let ops =
        other_nodes
        |> dict.get(l)
        |> result.unwrap([])
      let str =
        [acc, { ops |> list.map(direction_to_op) }, ["A"]]
        |> list.flatten
      use_keyboard(ls, Keyboard(l, keys), str)
    }
  }
}

pub fn direction_to_op(dir: Direction) -> String {
  case dir {
    North -> "^"
    South -> "v"
    East -> ">"
    West -> "<"
    _ -> panic as "Direction not supported"
  }
}

pub type Node {
  Node(id: String, other_nodes: Dict(String, List(Direction)))
}

pub type Keyboard {
  Keyboard(current_key: String, keys: Dict(String, Node))
}

pub fn create_number_keyboard() -> Keyboard {
  ["7", "8", "9", "4", "5", "6", "1", "2", "3", " ", "0", "A"]
  |> char_grid.from_list(3)
  |> build_keyboard_from_char_grid
}

pub fn create_direction_keyboard() -> Keyboard {
  [" ", "^", "A", "<", "v", ">"]
  |> char_grid.from_list(3)
  |> build_keyboard_from_char_grid
}

pub fn build_keyboard_from_char_grid(grid: CharGrid) -> Keyboard {
  grid
  |> char_grid.coords_fold(dict.new(), fn(acc, key, coords) {
    use <- bool.guard(key == " ", acc)
    let other_keys =
      find_paths(
        grid,
        [coords] |> set.from_list,
        [Pivot(coords, [], West)] |> deque.from_list,
        dict.new(),
      )
    acc |> dict.insert(key, Node(key, other_keys))
  })
  |> Keyboard("A", _)
}

pub fn find_paths(
  grid: CharGrid,
  visited: Set(Coords),
  queue: Deque(Pivot),
  acc: Dict(String, List(Direction)),
) -> Dict(String, List(Direction)) {
  let front = queue |> deque.pop_front
  use <- bool.guard(front |> result.is_error, acc)
  let assert Ok(#(Pivot(coords, ops, last_direction), queue)) = front

  let next =
    last_direction
    |> iter_non_diag_starting_at
    |> list.map(fn(d) { #(d, coords.move_in_direction(coords, d)) })
    |> list.filter_map(fn(t) {
      let #(d, c) = t
      use <- bool.guard(set.contains(visited, c), Error(Nil))
      case grid |> char_grid.get_tile(c) {
        Ok(" ") -> Error(Nil)
        Ok(l) -> Ok(#(c, l, ops |> list.append([d]), d))
        _ -> Error(Nil)
      }
    })

  let acc =
    next
    |> list.fold(acc, fn(acc, n) {
      let #(_, l, ops, _) = n
      acc
      |> dict.insert(l, ops)
    })
  let visited =
    visited |> set.union(next |> list.map(fn(t) { t.0 }) |> set.from_list)

  let queue =
    next
    |> list.fold(queue, fn(queue, t) {
      let #(c, _, ops, d) = t
      queue |> deque.push_back(Pivot(c, ops, d))
    })
  find_paths(grid, visited, queue, acc)
}

pub fn to_number_non_diag(dir: Direction) -> Int {
  case dir {
    West -> 0
    South -> 1
    East -> 2
    North -> 3
    _ -> panic as "Direction not supported"
  }
}

pub fn from_number_non_diag(num: Int) -> Direction {
  case num {
    0 -> West
    1 -> South
    2 -> East
    3 -> North
    _ -> panic as "Direction not supported"
  }
}

pub fn iter_non_diag_starting_at(dir: Direction) -> List(Direction) {
  let offset = dir |> to_number_non_diag
  list.range(0, 3)
  |> list.map(fn(i) { from_number_non_diag({ i + offset } % 4) })
}

pub type Pivot {
  Pivot(coords: Coords, ops: List(Direction), last_dir: Direction)
}

pub fn solution2(input: Input) -> Int {
  todo
}

pub type Input {
  Input(combinations: List(String))
}

pub fn read_input(path: String) -> Result(Input, String) {
  use content <- result.try(
    simplifile.read(path)
    |> result.map_error(fn(_) { "Could not read file" }),
  )
  content
  |> string.split("\n")
  |> list.filter(fn(s) { !string.is_empty(s) })
  |> Input
  |> Ok
}
