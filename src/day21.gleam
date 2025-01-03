import char_grid.{type CharGrid, CharGrid}
import coords.{type Coords, Coords}
import dict_util
import direction.{type Direction, East, North, South, West}
import gleam/bool
import gleam/deque.{type Deque}
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order.{type Order, Eq, Gt, Lt}
import gleam/regexp
import gleam/result
import gleam/set.{type Set}
import gleam/string
import glemo
import simplifile

const print_debug_output = False

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
  solution(input, 2)
}

pub fn solution(input: Input, times: Int) -> Int {
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
      |> apply_keyboard_to_last_output_n_times(
        number_keyboard,
        direction_keyboard,
        times,
      )
    num1 * num2
  })
  |> int.sum
}

pub fn apply_keyboard_to_last_output_n_times(
  graphemes: List(String),
  number_keys: Dict(String, Node),
  directional_keys: Dict(String, Node),
  directional_levels: Int,
) -> Int {
  glemo.init(["my_cache"])
  let res =
    split_into_instruction_sequences(graphemes)
    |> list.map(fn(g) {
      use_keyboard(g, number_keys, "A", [])
      |> list.map(fn(g) {
        apply_keyboard_minimize_substr(g, directional_keys, directional_levels)
      })
    })
    |> list.map(list.reduce(_, int.min))
    |> result.all
    |> result.lazy_unwrap(fn() { panic as "Empty sequence" })
    |> int.sum

  glemo.invalidate_all("my_cache")
  res
}

pub fn apply_keyboard_minimize_substr(
  graphemes: List(String),
  keys: Dict(String, Node),
  level: Int,
) -> Int {
  glemo.memo(#(graphemes, level), "my_cache", fn(t) {
    let #(g, l) = t
    apply_keyboard_minimize_substr_not_memo(g, keys, l)
  })
}

pub fn apply_keyboard_minimize_substr_not_memo(
  graphemes: List(String),
  keys: Dict(String, Node),
  level: Int,
) -> Int {
  case level {
    0 -> graphemes |> list.length
    _ ->
      split_into_instruction_sequences(graphemes)
      |> list.map(fn(g) {
        use_keyboard(g, keys, "A", [])
        |> list.map(fn(g) { apply_keyboard_minimize_substr(g, keys, level - 1) })
      })
      |> list.map(list.reduce(_, int.min))
      |> result.all
      |> result.lazy_unwrap(fn() { panic as "Empty sequence" })
      |> int.sum
  }
}

pub fn split_into_instruction_sequences(
  graphemes: List(String),
) -> List(List(String)) {
  {
    graphemes
    |> list.fold(#([], []), fn(acc, x) {
      let #(collected, current) = acc
      case x {
        "A" -> #([[x, ..current] |> list.reverse, ..collected], [])
        x -> #(collected, [x, ..current])
      }
    })
  }.0
}

pub fn use_keyboard(
  graphemes: List(String),
  keys: Dict(String, Node),
  current_key: String,
  acc: List(List(String)),
) -> List(List(String)) {
  case graphemes {
    [] -> acc |> list.map(list.reverse(_))
    [l, ..ls] -> {
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

      let acc = case ops, acc {
        [], [] -> [["A"]]
        [], acc ->
          acc
          |> list.map(fn(x) { ["A", ..x] })
        ops, [] ->
          ops
          |> list.fold([], fn(l, ops) {
            let a = create_op_string(ops)
            [["A", ..a], ..l]
          })
        ops, acc ->
          ops
          |> list.fold([], fn(l, ops) {
            let a = create_op_string(ops)
            [
              {
                acc
                |> list.map(fn(x) { ["A", ..{ [a, x] |> list.flatten }] })
              },
              l,
            ]
            |> list.flatten
          })
      }
      use_keyboard(ls, keys, l, acc)
    }
  }
}

pub fn create_op_string(ops: List(Direction)) -> List(String) {
  ops |> list.map(direction_to_op)
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
  Node(id: String, other_nodes: Dict(String, List(List(Direction))))
}

pub type Keyboard {
  Keyboard(current_key: String, keys: Dict(String, Node))
}

pub fn create_number_keyboard() -> Dict(String, Node) {
  ["7", "8", "9", "4", "5", "6", "1", "2", "3", " ", "0", "A"]
  |> char_grid.from_list(3)
  |> build_keyboard_from_char_grid
}

pub fn create_direction_keyboard() -> Dict(String, Node) {
  [" ", "^", "A", "<", "v", ">"]
  |> char_grid.from_list(3)
  |> build_keyboard_from_char_grid
}

pub fn build_keyboard_from_char_grid(grid: CharGrid) -> Dict(String, Node) {
  grid
  |> char_grid.coords_fold(dict.new(), fn(acc, key, coords) {
    use <- bool.guard(key == " ", acc)
    let other_keys =
      find_paths(
        grid,
        coords,
        [Pivot(coords, [])] |> deque.from_list,
        dict.new(),
        dict.new(),
      )
    acc |> dict.insert(key, Node(key, other_keys))
  })
}

pub fn find_paths(
  grid: CharGrid,
  starting_coords: Coords,
  queue: Deque(Pivot),
  shortest_distances: Dict(String, Int),
  acc: Dict(String, List(List(Direction))),
) -> Dict(String, List(List(Direction))) {
  let front = queue |> deque.pop_front
  use <- bool.guard(front |> result.is_error, acc)
  let assert Ok(#(Pivot(coords, ops), queue)) = front

  let next =
    direction.iter_non_diag()
    |> list.map(fn(d) { #(d, coords.move_in_direction(coords, d)) })
    |> list.filter_map(fn(t) {
      let #(d, c) = t
      use <- bool.guard(starting_coords == c, Error(Nil))
      use tile <- result.try(
        grid
        |> char_grid.get_tile(c)
        |> result.try(fn(l) {
          use <- bool.guard(l == " ", Error(Nil))
          Ok(l)
        }),
      )
      let ops_len = { ops |> list.length } + 1
      let is_bigger = case shortest_distances |> dict.get(tile) {
        Ok(n) if ops_len > n -> True
        _ -> False
      }
      use <- bool.guard(is_bigger, Error(Nil))
      let ops = [d, ..ops]
      Ok(#(c, tile, ops))
    })

  let shortest_distances =
    next
    |> list.fold(shortest_distances, fn(acc, t) {
      let #(_, tile, ops) = t
      acc |> dict.insert(tile, ops |> list.length)
    })

  let acc =
    next
    |> list.fold(acc, fn(acc, n) {
      let #(_, l, ops) = n
      acc
      |> dict_util.merge([#(l, [ops])] |> dict.from_list)
    })

  let queue =
    next
    |> list.fold(queue, fn(queue, t) {
      let #(c, _, ops) = t
      queue |> deque.push_back(Pivot(c, ops))
    })
  find_paths(grid, starting_coords, queue, shortest_distances, acc)
}

pub type Pivot {
  Pivot(coords: Coords, ops: List(Direction))
}

pub fn solution2(input: Input) -> Int {
  solution(input, 25)
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
