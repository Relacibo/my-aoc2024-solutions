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

pub const day_number_string = "day23"

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
  |> string.append("Problem 2 - Solution: ", _)
  |> io.println()
  Ok(Nil)
}

pub fn solution1(input: Input) -> Int {
  let Input(connections) = input
  build_graph(connections).nodes
  |> dict.values()
  |> list.flat_map(fn(node) {
    let Node(id, cs) = node
    cs
    |> list.combinations(2)
    |> list.map(list.prepend(_, id))
    |> list.map(list.sort(_, string.compare))
  })
  |> list.group(function.identity)
  |> dict.to_list
  |> list.filter_map(fn(t) {
    let #(k, v) = t
    use <- bool.guard(v |> list.length < 3, Error(Nil))
    Ok(k)
  })
  |> list.filter(fn(l) {
    l |> list.find(fn(s) { s |> string.starts_with("t") }) |> result.is_ok
  })
  // |> list.sort(fn(l1, l2) {
  //   string.compare(l1 |> string.concat, l2 |> string.concat)
  // })
  // |> io.debug
  |> list.length
}

pub fn solution2(input: Input) -> String {
  let Input(connections) = input
  let graph = build_graph(connections)
  let dummy = []
  list.range(3, 1000)
  |> list.fold_until(dummy, fn(last, i) {
    case find_interconnected_of_size(graph, i) {
      [] -> Stop(last)
      [first, ..] -> Continue(first)
    }
  })
  |> list.intersperse(",")
  |> string.concat
}

pub fn find_interconnected_of_size(
  graph: Graph,
  size: Int,
) -> List(List(String)) {
  graph.nodes
  |> dict.values()
  |> list.flat_map(fn(node) {
    let Node(id, cs) = node
    cs
    |> list.combinations(size - 1)
    |> list.map(list.prepend(_, id))
    |> list.map(list.sort(_, string.compare))
  })
  |> list.group(function.identity)
  |> dict.to_list
  |> list.filter_map(fn(t) {
    let #(k, v) = t
    use <- bool.guard(v |> list.length < size, Error(Nil))
    Ok(k)
  })
  |> list.filter(fn(l) {
    l |> list.find(fn(s) { s |> string.starts_with("t") }) |> result.is_ok
  })
}

pub fn build_graph(connections: List(#(String, String))) -> Graph {
  let nodes =
    connections
    |> list.fold(dict.new(), fn(acc, x) {
      let #(id1, id2) = x
      let l = [id1, id2]
      l
      |> list.zip(l |> list.reverse)
      |> list.fold(acc, fn(acc, t) {
        let #(c1, c2) = t
        case acc |> dict.get(c1) {
          Ok(Node(_, cs)) -> {
            acc |> dict.insert(c1, Node(c1, [c2, ..cs]))
          }
          Error(_) -> {
            acc |> dict.insert(c1, Node(c1, [c2]))
          }
        }
      })
    })
  Graph(nodes)
}

pub type Input {
  Input(connections: List(#(String, String)))
}

pub type Node {
  Node(id: String, connections: List(String))
}

pub type Graph {
  Graph(nodes: Dict(String, Node))
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
    let assert [p1, p2] = string.split(s, "-")
    #(p1, p2)
  })
  |> Input
  |> Ok
}
