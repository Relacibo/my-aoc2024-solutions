import gleam/dict.{type Dict}
import gleam/list

pub fn merge(
  dict1: Dict(a, List(b)),
  dict2: Dict(a, List(b)),
) -> Dict(a, List(b)) {
  dict1 |> dict.combine(dict2, fn(a, b) { [a, b] |> list.flatten })
}

pub fn merge_all(dicts: List(Dict(a, List(b)))) -> Dict(a, List(b)) {
  case dicts {
    [x] -> x
    [x, ..xs] -> {
      xs
      |> list.fold(x, fn(acc, d) { acc |> merge(d) })
    }
    [] -> dict.new()
  }
}
