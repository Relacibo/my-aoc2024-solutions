import gleam/bool
import gleam/dict.{type Dict}
import gleam/function
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/regexp
import gleam/result
import gleam/string
import glemo
import simplifile

pub const day_number_string = "day19"

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
  let Input(towels, patterns) = input

  patterns |> list.filter_map(search_for_pattern(_, towels)) |> list.length
}

pub fn search_for_pattern(
  pattern: String,
  towels: List(String),
) -> Result(Nil, Nil) {
  use <- bool.guard(string.is_empty(pattern), Ok(Nil))
  towels
  |> list.filter_map(fn(towel) {
    use <- bool.guard(!string.starts_with(pattern, towel), Error(Nil))
    Ok(pattern |> string.drop_start(string.length(towel)))
  })
  |> list.find_map(search_for_pattern(_, towels))
}

pub fn solution2(input: Input) -> Int {
  let Input(towels, patterns) = input

  patterns
  |> list.map(fn(pattern) {
    glemo.init(["find_all_matches_" <> pattern])
    let res =
      search_for_substrings(
        pattern |> string.to_graphemes,
        towels |> list.map(fn(t) { t |> string.to_graphemes }),
      )
      |> find_all_matches_memo(pattern, pattern |> string.length, 0)

    glemo.invalidate_all("find_all_matches_" <> pattern)
    res
  })
  |> int.sum
}

fn find_all_matches_memo(
  slices_map: Dict(Int, List(Int)),
  pattern: String,
  pattern_length: Int,
  index: Int,
) {
  glemo.memo(index, "find_all_matches_" <> pattern, fn(i) {
    find_all_matches(slices_map, pattern, pattern_length, i)
  })
}

pub fn search_for_substrings(
  pattern: List(String),
  towels: List(List(String)),
) -> Dict(Int, List(Int)) {
  let towels = towels |> list.group(fn(t) { t |> list.length })
  towels
  |> dict.to_list
  |> list.flat_map(fn(tup) {
    let #(len, ts) = tup
    pattern
    |> list.window(len)
    |> list.index_map(fn(sub_pattern, index) {
      use _ <- result.try(ts |> list.find(fn(t) { sub_pattern == t }))
      Ok(#(index, len))
    })
    |> list.filter_map(function.identity)
  })
  |> list.group(fn(t) { t.0 })
  |> dict.map_values(fn(_, l) { l |> list.map(fn(t) { t.1 }) })
}

pub fn find_all_matches(
  slices_map: Dict(Int, List(Int)),
  pattern: String,
  pattern_length: Int,
  index: Int,
) -> Int {
  use <- bool.guard(pattern_length <= index, 1)
  case slices_map |> dict.get(index) {
    Error(_) -> 0
    Ok(towels) -> {
      towels
      |> list.map(fn(len) {
        find_all_matches_memo(slices_map, pattern, pattern_length, index + len)
      })
      |> int.sum
    }
  }
}

pub type Input {
  Input(towel_types: List(String), patterns: List(String))
}

pub fn read_input(path: String) -> Result(Input, String) {
  use content <- result.try(
    simplifile.read(path)
    |> result.map_error(fn(_) { "Could not read file" }),
  )
  let assert [towels, patterns] =
    content
    |> string.split("\n\n")
  let towels = towels |> string.split(", ")
  let patterns =
    patterns
    |> string.split("\n")
    |> list.filter(fn(s) { !string.is_empty(s) })
  Ok(Input(towels, patterns))
}
