import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set
import gleam/string
import simplifile

pub const day_number_string = "day08"

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
  solution(input, Problem1)
}

pub fn solution2(input: Input) -> Int {
  solution(input, Problem2)
}

fn solution(input: Input, problem: Problem) -> Int {
  let Input(content, width, height) = input
  content
  |> list.map(fn(t) {
    let #(id, c) = t
    dict.new()
    |> dict.insert(id, [c])
  })
  |> list.reduce(fn(d1, d2) {
    dict.combine(d1, d2, fn(l1, l2) { [l1, l2] |> list.flatten })
  })
  |> result.unwrap(dict.new())
  |> dict.values()
  |> list.map(find_anti_nodes(_, width, height, problem))
  |> list.flatten
  |> set.from_list
  |> set.size
}

fn find_anti_nodes(
  nodes: List(Coords),
  width: Int,
  height: Int,
  problem: Problem,
) -> List(Coords) {
  nodes
  |> list.combination_pairs
  |> list.flat_map(get_antinodes(_, width, height, problem))
}

fn get_antinodes(
  nodes: #(Coords, Coords),
  width: Int,
  height: Int,
  problem: Problem,
) -> List(Coords) {
  let #(node1, node2) = nodes
  let Coords(x1, y1) = node1
  let Coords(x2, y2) = node2
  case problem {
    Problem1 ->
      [Coords(2 * x1 - x2, 2 * y1 - y2), Coords(2 * x2 - x1, 2 * y2 - y1)]
      |> list.filter(is_in_bound(_, width, height))
    Problem2 ->
      [node1, node2]
      |> list.permutations
      |> list.flat_map(fn(v) {
        let assert [node1, node2] = v
        extrapolate([node1], subtract_coords(node2, node1), width, height)
      })
  }
}

fn extrapolate(
  acc: List(Coords),
  delta: Coords,
  width: Int,
  height: Int,
) -> List(Coords) {
  let assert [last_node, ..] = acc
  let coords = add_coords(last_node, delta)
  case is_in_bound(coords, width, height) {
    True -> extrapolate([coords, ..acc], delta, width, height)
    False -> acc
  }
}

fn add_coords(coords1: Coords, coords2: Coords) -> Coords {
  let Coords(x1, y1) = coords1
  let Coords(x2, y2) = coords2
  Coords(x1 + x2, y1 + y2)
}

fn subtract_coords(coords1: Coords, coords2: Coords) -> Coords {
  let Coords(x1, y1) = coords1
  let Coords(x2, y2) = coords2
  Coords(x1 - x2, y1 - y2)
}

fn is_in_bound(coords: Coords, width: Int, height: Int) -> Bool {
  let Coords(x, y) = coords
  x >= 0 && x < width && y >= 0 && y < height
}

pub fn read_input(path: String) -> Result(Input, String) {
  use lines <- result.try(
    simplifile.read(path)
    |> result.map_error(fn(_) { "Could not read file" }),
  )
  let rows =
    lines
    |> string.split("\n")
    |> list.filter(fn(s) { !string.is_empty(s) })

  let height =
    rows
    |> list.length

  use width <- result.try(
    rows
    |> list.first()
    |> result.map(string.length)
    |> result.map_error(fn(_) { "Row empty!" }),
  )

  let content =
    rows
    |> list.index_map(fn(row, y) {
      row
      |> string.to_graphemes
      |> list.index_map(fn(g, x) {
        case g {
          "." -> []
          id -> [#(id, Coords(x, y))]
        }
      })
      |> list.flatten
    })
    |> list.flatten
  Ok(Input(content, width, height))
}

pub type Input {
  Input(content: List(#(String, Coords)), width: Int, height: Int)
}

pub type Coords {
  Coords(x: Int, y: Int)
}

pub type Problem {
  Problem1
  Problem2
}
