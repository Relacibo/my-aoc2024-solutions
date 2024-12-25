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
  todo
}

pub fn solution2(input: Input) -> Int {
  todo
}

pub type Input {
  Input(initial: Dict(Id, Bool), ops: List(Operation))
}

pub type Id {
  Id(id: String, number: Option(Int))
}

pub type Unsolved {
  Unsolved(op: Operation, a: Option(Bool), b: Option(Bool))
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

pub type Operation {
  Xor(a: Id, b: Id, res: Id)
  And(a: Id, b: Id, res: Id)
  Or(a: Id, b: Id, res: Id)
}

pub fn read_input(path: String) -> Result(Input, String) {
  use content <- result.try(
    simplifile.read(path)
    |> result.map_error(fn(_) { "Could not read file" }),
  )
  let assert [part_a, part_b] =
    content
    |> string.split("\n^\n")
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
      #(a |> parse_id, value)
    })
    |> dict.from_list

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
        "XOR" -> Xor(a, b, res)
        "OR" -> Or(a, b, res)
        "AND" -> And(a, b, res)
        _ -> panic as "unexpected operation"
      }
    })
  Ok(Input(initial, ops))
}
