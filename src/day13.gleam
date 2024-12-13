import coords.{type Coords, Coords}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/regexp
import gleam/result
import gleam/string
import simplifile

pub const day_number_string = "day13"

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
  let Input(elems) = input
}

pub fn solution2(input: Input) -> Int {
  todo
}

pub type Input {
  Input(List(InputElem))
}

pub type InputElem {
  InputElem(a: Coords, b: Coords, total: Coords)
}

pub fn read_input(path: String) -> Result(Input, String) {
  use content <- result.try(
    simplifile.read(path)
    |> result.map_error(fn(_) { "Could not read file" }),
  )
  let options = regexp.Options(case_insensitive: False, multi_line: True)
  let assert Ok(regex) =
    regexp.compile(
      "^Button A: X\\+([^,]+), Y\\+(.+)\nButton B: X\\+([^,]+), Y\\+(.+)\nPrize: X=([^,]+), Y=(.+)$",
      options,
    )
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
    let assert [x1, y1, x2, y2, t1, t2] = sm
    InputElem(Coords(x1, y1), Coords(x2, y2), Coords(t1, t2))
  })
  |> Input
  |> Ok
}
