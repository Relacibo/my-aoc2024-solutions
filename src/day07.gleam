import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

// import gleam/float
// import gleam_community/maths/elementary

pub const day_number_string = "day07"

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

pub type InputRow {
  InputRow(res: Int, elems: List(Int))
}

pub fn read_input(path: String) -> Result(List(InputRow), String) {
  use content <- result.try(
    simplifile.read(path)
    |> result.map_error(fn(_) { "Could not read file" }),
  )
  content
  |> string.split("\n")
  |> list.filter(fn(s) { !string.is_empty(s) })
  |> list.map(read_input_row)
  |> result.all
}

fn read_input_row(row: String) -> Result(InputRow, String) {
  case string.split(row, ": ") {
    [res, tail] -> {
      use res <- result.try(
        res |> int.parse() |> result.map_error(fn(_) { "Parsing Int failed" }),
      )
      use elems <- result.try(
        string.split(tail, " ")
        |> list.map(int.parse)
        |> result.all
        |> result.map_error(fn(_) { "Parsing Int failed" }),
      )
      Ok(InputRow(res, elems))
    }
    _ -> Error("Parsing failed")
  }
}

pub fn solution1(input: List(InputRow)) -> Int {
  let ops = [int.add, int.multiply]
  input
  |> list.filter(fn(row) { check_result_helper(row.elems, row.res, 0, ops) })
  |> list.map(fn(r) { r.res })
  |> list.reduce(int.add)
  |> result.unwrap(0)
}

pub fn solution2(input: List(InputRow)) -> Int {
  let ops = [
    int.add,
    int.multiply,
    fn(a: Int, b: Int) {
      // Doesn't work:
      // a
      // * {
      //   b
      //   |> int.to_float
      //   |> elementary.logarithm_10
      //   |> result.unwrap(0.0)
      //   |> fn(f) { f +. 1.0 }
      //   |> elementary.power(10.0, _)
      //   |> result.unwrap(0.0)
      //   |> float.round()
      // }
      // + b
      let assert Ok(res) =
        { int.to_string(a) <> int.to_string(b) }
        |> int.parse
      res
    },
  ]
  input
  |> list.filter(fn(row) { check_result_helper(row.elems, row.res, 0, ops) })
  |> list.map(fn(r) { r.res })
  |> list.reduce(int.add)
  |> result.unwrap(0)
}

fn check_result_helper(
  elems: List(Int),
  wanted: Int,
  acc: Int,
  ops: List(fn(Int, Int) -> Int),
) -> Bool {
  case elems {
    [] -> acc == wanted
    [elem, ..rest] -> {
      ops
      |> list.map(fn(op) { op(acc, elem) })
      |> list.filter(fn(acc) { acc <= wanted })
      |> list.any(check_result_helper(rest, wanted, _, ops))
    }
  }
}
