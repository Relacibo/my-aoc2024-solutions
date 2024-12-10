import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub const day_number_string = "y2023day01"

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

fn is_digit_char(s: String) -> Bool {
  case
    s
    |> string.to_utf_codepoints
    |> list.map(fn(c) { c |> string.utf_codepoint_to_int })
  {
    [c] if c >= 48 && c < 58 -> True
    _ -> False
  }
}

pub fn solution1(input: Input) -> Int {
  let Input(rows) = input
  rows
  |> list.map(string.to_graphemes)
  |> list.filter_map(fn(row) {
    use f <- result.try(row |> list.find(is_digit_char))
    use l <- result.try(row |> list.reverse() |> list.find(is_digit_char))
    { f <> l }
    |> int.parse
  })
  |> int.sum
}

pub fn solution2(input: Input) -> Int {
  let Input(rows) = input
  rows
  |> list.map(string.to_graphemes)
  |> list.filter_map(fn(row) {
    let table = [
      #(3, [#("one", 1), #("two", 2), #("six", 6)]),
      #(4, [#("four", 4), #("five", 5), #("nine", 9)]),
      #(5, [#("three", 3), #("seven", 7), #("eight", 8)]),
    ]
    let lettered =
      table
      |> list.flat_map(fn(entry) {
        let #(letter_count, digits) = entry
        row
        |> list.window(letter_count)
        |> list.index_fold([], fn(acc, sub_str, index) {
          let sub_str = sub_str |> string.concat
          case
            digits
            |> list.find_map(fn(digit) {
              let #(digit_str, n) = digit
              case sub_str == digit_str {
                True -> Ok(n)
                False -> Error(Nil)
              }
            })
          {
            Ok(n) -> [#(index, n), ..acc]
            Error(_) -> acc
          }
        })
      })
    let real =
      row
      |> list.index_map(fn(a, i) { #(i, a) })
      |> list.filter_map(fn(t) {
        let #(index, d) = t
        case is_digit_char(d) {
          True -> {
            let assert Ok(i) = int.parse(d)
            Ok(#(index, i))
          }
          False -> Error(Nil)
        }
      })
    let digits =
      [lettered, real]
      |> list.flatten
      |> list.sort(fn(a, b) { int.compare(a.0, b.0) })
    use found <- result.try(
      [digits |> list.first(), digits |> list.last()]
      |> result.all(),
    )
    found
    |> list.map(fn(t) { int.to_string(t.1) })
    |> string.concat
    |> int.parse
  })
  |> int.sum
}

pub type Input {
  Input(rows: List(String))
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
