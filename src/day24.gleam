import char_grid.{type CharGrid, CharGrid}
import coords.{type Coords, Coords}
import dict_util
import direction.{type Direction, East, North, South, West}
import gleam/bool
import gleam/deque.{type Deque}
import gleam/dict.{type Dict}
import gleam/function
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list.{Continue, Stop}
import gleam/option.{type Option, None, Some}
import gleam/order.{type Order, Eq, Gt, Lt}
import gleam/regexp
import gleam/result
import gleam/set.{type Set}
import gleam/string
import simplifile

pub const day_number_string = "day24"

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
  let Input(initial, ops) = input
  build_lookup(initial, ops) |> solve_z
}

pub fn solution2(input: Input) -> Int {
  let Input(initial, ops) = input
  todo
}

pub type Node {
  Node(op: Operation, children: List(Node))
  Leaf(id: Id)
}

pub fn solve_z(ops: Dict(Id, Operation)) -> Int {
  list.range(0, 64)
  |> list.map(fn(x) { Id("z", Some(x)) })
  |> list.take_while(fn(x) { ops |> dict.get(x) |> result.is_ok })
  |> list.reverse
  |> list.map(fn(x) { solve(x, ops) })
  |> result.all
  |> result.lazy_unwrap(fn() { panic as "Error happened" })
  |> list.fold(0, fn(acc, x) {
    int.bitwise_or(acc |> int.bitwise_shift_left(1), x |> bool.to_int)
  })
}

pub fn solve(id: Id, ops: Dict(Id, Operation)) -> Result(Bool, Nil) {
  use op <- result.try(ops |> dict.get(id))
  case op {
    Binary(_, op, a, b) -> {
      use a <- result.try(solve(a, ops))
      use b <- result.try(solve(b, ops))
      let op = case op {
        Xor -> bool.exclusive_or
        Or -> bool.or
        And -> bool.and
      }
      Ok(op(a, b))
    }
    Initial(_, val) -> Ok(val)
  }
}

pub fn build_lookup(
  initial: List(Operation),
  input: List(Operation),
) -> Dict(Id, Operation) {
  [initial, input]
  |> list.flatten
  |> list.fold(dict.new(), fn(acc, op) { acc |> dict.insert(op.res, op) })
}

pub type Input {
  Input(initial: List(Operation), ops: List(Operation))
}

pub type Id {
  Id(id: String, number: Option(Int))
}

pub fn parse_id(val: String) -> Id {
  let #(id, letter_string) =
    val
    |> string.to_graphemes
    |> list.split_while(fn(num) { int.parse(num) |> result.is_error })
  let number =
    letter_string
    |> string.concat
    |> int.parse
    |> option.from_result
  let id = id |> string.concat
  Id(id, number)
}

pub fn id_to_string(id: Id) -> String {
  let Id(id, number) = id
  id
  <> {
    number
    |> option.map(fn(x) { x |> int.to_string |> string.pad_start(2, "0") })
    |> option.unwrap("")
  }
}

pub type BinaryOp {
  Xor
  And
  Or
}

pub type Operation {
  Binary(res: Id, op: BinaryOp, a: Id, b: Id)
  Initial(res: Id, val: Bool)
}

pub fn read_input(path: String) -> Result(Input, String) {
  use content <- result.try(
    simplifile.read(path)
    |> result.map_error(fn(_) { "Could not read file" }),
  )
  let assert [part_a, part_b] =
    content
    |> string.split("\n\n")
    |> list.filter(fn(s) { !string.is_empty(s) })
  let initial =
    part_a
    |> string.split("\n")
    |> list.map(fn(s) {
      let assert [a, b] =
        s
        |> string.split(": ")

      let value = case b {
        "0" -> False
        "1" -> True
        _ -> panic as "Input broken!"
      }
      Initial(a |> parse_id, value)
    })

  let options = regexp.Options(case_insensitive: False, multi_line: True)
  let assert Ok(regex) =
    regexp.compile("^([^ ]+) (X?OR|AND) ([^ ]+) -> ([^ ]+)$", options)
  let ops =
    regex
    |> regexp.scan(part_b)
    |> list.map(fn(m) {
      let assert [a, op, b, res] =
        m.submatches
        |> list.map(option.lazy_unwrap(_, fn() { panic as "regex didnt match" }))

      let assert [a, b, res] = [a, b, res] |> list.map(parse_id)

      case op {
        "XOR" -> Binary(res, Xor, a, b)
        "OR" -> Binary(res, Or, a, b)
        "AND" -> Binary(res, And, a, b)
        _ -> panic as "unexpected operation"
      }
    })
  Ok(Input(initial, ops))
}
