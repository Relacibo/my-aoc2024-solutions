import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/queue
import gleam/result
import gleam/set.{type Set}
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
  let #(used, space) =
    file_blocks
    |> list.unzip
  let free_space_map = create_free_space_to_index_map(space)

  used
  |> list.reverse
  |> find_free_spaces_solution2(free_space_map, dict.new())
  |> calculate_checksum
}

pub fn find_free_spaces_solution2(
  rev: List(File),
  free_space_map: FreeSpaceMap,
  files: Dict(Int, List(File)),
) -> List(DiskBlocks) {
  case rev {
    [] -> collect_finished_state(free_space_map, files)
    [File(id_rev, size_rev) as file_rev, ..rest_rev] -> {
      case
        use_first_free_space(
          free_space_map.index_to_size,
          free_space_map.size_to_index,
          [],
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
      {
        Ok(#(free_space_map_new, index)) ->
          find_free_spaces_solution2(
            rest_rev,
            free_space_map_new,
            files
              |> dict.combine(
                dict.new() |> dict.insert(index, [file_rev]),
                fn(l1, l2) {
                  let assert [l2] = l2
                  [l2, ..l1]
                },
              ),
          )
        Error(_) ->
          find_free_spaces_solution2(
            rest_rev,
            free_space_map,
            files
              |> dict.combine(
                dict.new() |> dict.insert(id_rev, [file_rev]),
                fn(l1, l2) { [l1, l2] |> list.flatten },
              ),
          )
      }
    }
  }
}

pub fn collect_finished_state(
  free_space_map: FreeSpaceMap,
  files: Dict(Int, List(File)),
) -> List(DiskBlocks) {
  files
  |> dict.map_values(fn(_, v) { v |> list.map(FileBlocks) })
  |> dict.combine(
    free_space_map.index_to_size
      |> dict.map_values(fn(_, size) { [FreeSpaceBlocks(FreeSpace(size))] }),
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
}

pub fn create_free_space_to_index_map(disk: List(FreeSpace)) -> FreeSpaceMap {
  let #(index_to_size, size_to_index) =
    disk
    |> list.index_fold(#(dict.new(), dict.new()), fn(acc, block, index) {
      let FreeSpace(size) = block
      let #(its, sti) = acc
      let its = its |> dict.insert(index, size)
      let sti =
        case dict.get(sti, size) {
          Ok(v) -> [index, ..v]
          Error(_) -> [index]
        }
        |> dict.insert(sti, size, _)
      #(its, sti)
    })
  let size_to_index =
    size_to_index
    |> dict.map_values(fn(_, val) { list.reverse(val) })
    |> dict.to_list
    |> list.sort(fn(a, b) {
      let #(key_a, _) = a
      let #(key_b, _) = b
      int.compare(key_a, key_b)
    })
  FreeSpaceMap(index_to_size, size_to_index)
}

pub fn use_first_free_space(
  index_to_size: Dict(Int, Int),
  to_be_searched_sti: List(#(Int, List(Int))),
  searched_sti: List(#(Int, List(Int))),
  used_indices_without_elem: List(Int),
  index_move_from: Int,
  size_wanted: Int,
) -> Result(#(FreeSpaceMap, Int), Nil) {
  case to_be_searched_sti {
    [] -> Error(Nil)
    [#(size, [index, ..]) as entry, ..rest]
      if size < size_wanted || index >= index_move_from
    ->
      use_first_free_space(
        index_to_size,
        rest,
        [entry, ..searched_sti],
        used_indices_without_elem,
        index_move_from,
        size_wanted,
      )
    [#(size, [index, ..indices_rest]), ..rest] -> {
      let index_to_size = index_to_size |> dict.delete(index)
      let searched_sti = searched_sti |> list.reverse
      let #(index_to_size, searched_sti) = case size > size_wanted {
        True ->
          insert_free_space(
            index_to_size,
            searched_sti,
            index,
            size - size_wanted,
          )
        False -> #(index_to_size, searched_sti)
      }
      let remains = case indices_rest {
        [] -> []
        indices_rest -> [#(size, indices_rest)]
      }
      Ok(#(
        [searched_sti, remains, rest]
          |> list.flatten
          |> FreeSpaceMap(index_to_size, _)
          |> insert_free_space_and_cleanup(
            [index, ..used_indices_without_elem]
              |> list.sort(int.compare)
              |> list.unique,
            index_move_from - 1,
            size_wanted,
          ),
        index,
      ))
    }
    _ -> panic as "Invariant broken: indices list cannot be empty"
  }
}

pub fn insert_free_space_and_cleanup(
  fsp: FreeSpaceMap,
  sorted_used_indices: List(Int),
  index: Int,
  size: Int,
) -> FreeSpaceMap {
  let FreeSpaceMap(index_to_size, list) = fsp
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

  let #(index_to_size, list, space) =
    remove_free_space_for_indices(
      index_to_size,
      list,
      list.range(delete_from, to),
    )

  insert_free_space(index_to_size, list, delete_from, size + space)
  |> fn(t) {
    let #(its, sti) = t
    FreeSpaceMap(its, sti)
  }
}

pub fn remove_free_space_for_indices(
  index_to_size: Dict(Int, Int),
  list: List(#(Int, List(Int))),
  indices: List(Int),
) -> #(Dict(Int, Int), List(#(Int, List(Int))), Int) {
  indices
  |> list.fold(#(index_to_size, list, 0), fn(acc, index) {
    let #(index_to_size, list, sum) = acc
    case
      index_to_size
      |> dict.get(index)
    {
      Ok(size) -> {
        let #(before, after) =
          list
          |> list.split_while(fn(t) {
            let #(s, _) = t
            s < size
          })
        let assert [l, ..after] = after

        let #(_, indices) = l
        let #(elems, indices) = indices |> list.partition(fn(i) { index == i })
        let index_to_size = index_to_size |> dict.delete(index)
        let sum = sum + size
        case elems, indices {
          [], _ -> {
            panic as "Invariant broken: index_to_size pointed to list, that doesn't contain index."
          }
          _, [] -> #(index_to_size, [before, after] |> list.flatten, sum)
          _, _ -> #(
            index_to_size,
            [before, [#(size, indices)], after] |> list.flatten,
            sum,
          )
        }
      }
      _ -> acc
    }
  })
}

pub fn insert_free_space(
  index_to_size: Dict(Int, Int),
  list: List(#(Int, List(Int))),
  index_free_space: Int,
  size_free_space: Int,
) -> #(Dict(Int, Int), List(#(Int, List(Int)))) {
  let #(smaller, bigger_equal) =
    list
    |> list.split_while(fn(t) {
      let #(s, _) = t
      s < size_free_space
    })
  let index_to_size =
    dict.insert(index_to_size, index_free_space, size_free_space)
  case bigger_equal {
    [#(s, l), ..rest] if s == size_free_space -> #(
      index_to_size,
      [
        smaller,
        [
          #(s, {
            let #(before, after) =
              l
              |> list.split_while(fn(s) { s < size_free_space })
            [before, [index_free_space], after]
            |> list.flatten
          }),
        ],
        rest,
      ]
        |> list.flatten,
    )

    _ -> #(
      index_to_size,
      [smaller, [#(size_free_space, [index_free_space])], bigger_equal]
        |> list.flatten,
    )
  }
}

pub fn calculate_checksum(l: List(DiskBlocks)) -> Int {
  let #(_, sum) =
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
  sum
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

pub fn debug_state(
  rev: List(File),
  free_space_map: FreeSpaceMap,
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
    free_space_map.size_to_index
      |> list.flat_map(fn(t) {
        let #(size, indices) = t
        indices
        |> list.map(fn(i) { dict.new() |> dict.insert(i, size) })
        |> list.fold(dict.new(), fn(acc, d) {
          dict.combine(acc, d, fn(a, b) { a + b })
        })
        |> dict.to_list
      })
      |> dict.from_list
      |> dict.map_values(fn(_, size) { [FreeSpaceBlocks(FreeSpace(size))] }),
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
