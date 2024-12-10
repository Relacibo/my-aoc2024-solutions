import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/result
import gleam/string
import simplifile

pub const day_number_string = "day09"

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
  let Input(file_blocks) = input
  let disk =
    file_blocks
    |> list.flat_map(fn(t) {
      let #(file, free_space) = t
      [FileBlocks(file), FreeSpaceBlocks(free_space)]
    })

  file_blocks
  |> list.map(fn(t) {
    let #(file, _) = t
    file
  })
  |> list.reverse
  |> fill_free_space(disk, [])
  |> list.reverse
  |> list.map(FileBlocks)
  |> calculate_checksum
}

fn fill_free_space(
  rev: List(File),
  disk: List(DiskBlocks),
  acc: List(File),
) -> List(File) {
  case rev, disk {
    // stop condition
    [File(id_rev, _) as file_rev, ..], [FileBlocks(File(id, _)), ..]
      if id >= id_rev
    -> {
      [file_rev, ..acc]
    }

    // move files to the accumulator
    _, [FileBlocks(file), ..disk_rest] ->
      fill_free_space(rev, disk_rest, [file, ..acc])

    // Ignore zero sized free space
    _, [FreeSpaceBlocks(FreeSpace(free_space)), ..disk_rest] if free_space <= 0 ->
      fill_free_space(rev, disk_rest, acc)

    [File(id, block_size) as file, ..rest_rev],
      [FreeSpaceBlocks(FreeSpace(size_free)), ..disk_rest]
    ->
      case int.compare(block_size, size_free) {
        order.Eq -> fill_free_space(rest_rev, disk_rest, [file, ..acc])
        order.Lt ->
          fill_free_space(
            rest_rev,
            [FreeSpaceBlocks(FreeSpace(size_free - block_size)), ..disk_rest],
            [file, ..acc],
          )
        order.Gt ->
          fill_free_space(
            [File(id, block_size - size_free), ..rest_rev],
            disk_rest,
            [File(id, size_free), ..acc],
          )
      }
    _, _ -> panic
  }
}

pub fn solution2(input: Input) -> Int {
  let Input(file_blocks) = input

  let all =
    file_blocks
    |> list.flat_map(fn(t) {
      let #(file, space) = t
      [FileBlocks(file), FreeSpaceBlocks(space)]
    })
    |> cleanup_disk_blocks([])

  let used =
    all
    |> list.filter_map(fn(f) {
      case f {
        FileBlocks(f) -> Ok(f)
        _ -> Error(Nil)
      }
    })

  let free_space_map = create_free_space_to_index_map(all)
  // io.debug(state_to_string(used, free_space_map, dict.new()))

  used
  |> list.reverse
  |> find_free_spaces_solution2(free_space_map, dict.new())
  |> calculate_checksum
}

fn cleanup_disk_blocks(
  files: List(DiskBlocks),
  acc: List(DiskBlocks),
) -> List(DiskBlocks) {
  case files {
    [FileBlocks(File(_, size)) as file, ..rest] if size > 0 ->
      cleanup_disk_blocks(rest, [file, ..acc])
    [] -> acc |> list.reverse
    _ -> {
      let #(empty, not_empty) =
        files
        |> list.split_while(fn(block) {
          case block {
            FileBlocks(File(_, size)) if size == 0 -> True
            FreeSpaceBlocks(_) -> True
            _ -> False
          }
        })
      let space_size =
        empty
        |> list.flat_map(fn(block) {
          case block {
            FileBlocks(_) -> []
            FreeSpaceBlocks(FreeSpace(size)) -> [size]
          }
        })
        |> int.sum
      cleanup_disk_blocks(not_empty, [
        FreeSpaceBlocks(FreeSpace(space_size)),
        ..acc
      ])
    }
  }
}

pub fn find_free_spaces_solution2(
  rev: List(File),
  free_space_map: List(#(Int, Int)),
  files: Dict(Int, List(File)),
) -> List(DiskBlocks) {
  case rev {
    [] -> {
      // io.debug(state_to_string([], free_space_map, files))
      collect_finished_state(free_space_map, files)
    }
    [File(id_rev, size_rev) as file_rev, ..rest_rev] -> {
      case
        free_space_map
        |> list.take_while(fn(t) { t.0 < id_rev })
        |> list.filter(fn(t) { t.1 >= size_rev })
        |> list.take(1)
      {
        [] ->
          find_free_spaces_solution2(
            rest_rev,
            free_space_map,
            files
              |> dict.combine(
                dict.new() |> dict.insert(id_rev, [file_rev]),
                fn(l1, l2) { [l1, l2] |> list.flatten },
              ),
          )

        [#(index, _) as elem, ..] -> {
          let free_space_map =
            take_free_space(
              free_space_map,
              elem,
              [
                rest_rev
                  |> list.map(fn(f) {
                    let File(id, _) = f
                    id
                  }),
                files
                  |> dict.keys,
              ]
                |> list.flatten,
              id_rev,
              size_rev,
            )

          find_free_spaces_solution2(
            rest_rev,
            free_space_map,
            files
              |> dict.combine(
                dict.new() |> dict.insert(index, [file_rev]),
                fn(l1, l2) {
                  let assert [l2] = l2
                  [l2, ..l1]
                },
              ),
          )
        }
      }
    }
  }
}

pub fn collect_finished_state(
  free_space_map: List(#(Int, Int)),
  files: Dict(Int, List(File)),
) -> List(DiskBlocks) {
  files
  |> dict.map_values(fn(_, v) { v |> list.map(FileBlocks) })
  |> dict.combine(
    free_space_map
      |> list.map(fn(t) { #(t.0, [FreeSpaceBlocks(FreeSpace(t.1))]) })
      |> dict.from_list,
    fn(l1, l2) { [l2, l1] |> list.flatten },
  )
  |> dict.to_list
  |> list.sort(fn(a, b) { int.compare(a.0, b.0) })
  |> list.flat_map(fn(t) { t.1 |> list.reverse })
}

pub fn create_free_space_to_index_map(
  disk: List(DiskBlocks),
) -> List(#(Int, Int)) {
  disk
  |> list.fold(#([], 0), fn(acc, block) {
    let #(its, index) = acc
    case block {
      FreeSpaceBlocks(FreeSpace(size)) -> {
        #([#(index, size), ..its], index)
      }
      FileBlocks(File(id, _)) -> #(its, id)
    }
  })
  |> fn(t) { t.0 }
  |> list.reverse
}

pub fn take_free_space(
  index_to_size: List(#(Int, Int)),
  first_free_space: #(Int, Int),
  used_indices_without_elem: List(Int),
  index_move_from: Int,
  size_wanted: Int,
) -> List(#(Int, Int)) {
  let #(index, size) = first_free_space
  let index_to_size = index_to_size |> list.filter(fn(t) { t.0 != index })
  let index_to_size = case size > size_wanted {
    True -> insert_int_tuple(index_to_size, #(index, size - size_wanted))
    False -> index_to_size
  }
  insert_free_space_and_cleanup(
    index_to_size,
    [index, ..used_indices_without_elem]
      |> list.sort(int.compare)
      |> list.unique,
    index_move_from - 1,
    size_wanted,
  )
}

pub fn insert_free_space_and_cleanup(
  index_to_size: List(#(Int, Int)),
  sorted_used_indices: List(Int),
  index: Int,
  size: Int,
) -> List(#(Int, Int)) {
  let to = case
    sorted_used_indices
    |> list.contains(index + 1)
  {
    False -> index
    True -> index
  }

  let delete_from =
    sorted_used_indices
    |> list.reverse
    |> list.find(fn(x) { x <= index })
    |> result.unwrap(0)

  cleanup(index_to_size, delete_from, to, size)
}

pub fn cleanup(
  index_to_size: List(#(Int, Int)),
  from: Int,
  to: Int,
  added_size: Int,
) -> List(#(Int, Int)) {
  let #(before, list) = index_to_size |> list.split_while(fn(t) { t.0 < from })
  let #(list, after) = list |> list.split_while(fn(t) { t.0 <= to })

  let sum = list |> list.map(fn(t) { t.1 }) |> int.sum
  [before, [#(from, added_size + sum)], after] |> list.flatten
}

pub fn calculate_checksum(l: List(DiskBlocks)) -> Int {
  l
  |> list.fold(#(0, 0), fn(acc, block) {
    let #(lower, sum) = acc
    case block {
      FileBlocks(File(id, block_size)) -> {
        let upper = lower + block_size
        // id * (small gauss(upper - 1) - small gauss(lower - 1))
        let elem = id * { upper * { upper - 1 } - lower * { lower - 1 } } / 2
        #(lower + block_size, sum + elem)
      }
      FreeSpaceBlocks(FreeSpace(free_space)) -> {
        #(lower + free_space, sum)
      }
    }
  })
  |> fn(t) { t.1 }
}

pub type Input {
  Input(content: List(#(File, FreeSpace)))
}

pub type DiskBlocks {
  FileBlocks(File)
  FreeSpaceBlocks(FreeSpace)
}

pub type File {
  File(id: Int, block_size: Int)
}

pub type FreeSpace {
  FreeSpace(block_size: Int)
}

pub fn read_input(path: String) -> Result(Input, String) {
  use content <- result.try(
    simplifile.read(path)
    |> result.map_error(fn(_) { "Could not read file" }),
  )
  use ints <- result.try(
    content
    |> string.split("\n")
    |> list.first
    |> result.unwrap("")
    |> string.to_graphemes
    |> list.map(int.parse)
    |> result.all
    |> result.map_error(fn(_) { "Not all input letters are Integer" }),
  )
  ints
  |> list.sized_chunk(2)
  |> list.index_map(fn(a, id) {
    case a {
      [block_size, block_size_empty] -> [
        #(File(id, block_size), FreeSpace(block_size_empty)),
      ]
      [block_size] -> [#(File(id, block_size), FreeSpace(0))]
      _ -> []
    }
  })
  |> list.flatten
  |> Input
  |> Ok
}

pub fn state_to_string(
  rev: List(File),
  free_space_map: List(#(Int, Int)),
  files: Dict(Int, List(File)),
) {
  let rev =
    rev
    |> list.map(fn(file) {
      let File(id, _) = file
      #(id, [file])
    })
    |> dict.from_list
  rev
  |> dict.combine(files, fn(orig, added) { [added, orig] |> list.flatten })
  |> dict.map_values(fn(_, v) { v |> list.map(FileBlocks) })
  |> dict.combine(
    free_space_map
      |> list.map(fn(t) { #(t.0, [FreeSpaceBlocks(FreeSpace(t.1))]) })
      |> dict.from_list,
    fn(l1, l2) { [l2, l1] |> list.flatten },
  )
  |> dict.to_list
  |> list.sort(fn(a, b) {
    let #(key_a, _) = a
    let #(key_b, _) = b
    int.compare(key_a, key_b)
  })
  |> list.flat_map(fn(t) {
    let #(_, entries) = t
    entries |> list.reverse
  })
  |> list.flat_map(fn(l) {
    case l {
      FileBlocks(File(id, size)) -> id |> int.to_string |> list.repeat(size)
      FreeSpaceBlocks(FreeSpace(size)) -> "." |> list.repeat(size)
    }
  })
  |> string.concat
}

pub type FreeSpaceMap {
  FreeSpaceMap(
    index_to_size: Dict(Int, Int),
    size_to_index: List(#(Int, List(Int))),
  )
}

pub fn insert_sorted(l: List(a), elem: a, f: fn(a, a) -> order.Order) -> List(a) {
  let #(before, after) =
    l
    |> list.split_while(fn(other) {
      case f(elem, other) {
        order.Gt -> True
        _ -> False
      }
    })
  [before, [elem], after] |> list.flatten
}

pub fn insert_int_tuple(l: List(#(Int, a)), elem: #(Int, a)) -> List(#(Int, a)) {
  let #(before, after) =
    l
    |> list.split_while(fn(other) {
      case int.compare(elem.0, other.0) {
        order.Gt -> True
        _ -> False
      }
    })
  [before, [elem], after] |> list.flatten
}
