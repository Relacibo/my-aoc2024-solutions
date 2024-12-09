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
  // solution2(input)
  // |> int.to_string
  // |> string.append("Problem 2 - Solution: ", _)
  // |> io.println()
  Ok(Nil)
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

pub fn solution1(input: Input) -> Int {
  let Input(file_blocks) = input
  let #(_, sum) =
    file_blocks
    |> list.map(fn(t) {
      let #(file, _) = t
      file
    })
    |> list.reverse
    |> fill_free_space(
      file_blocks
        |> list.flat_map(fn(t) {
          let #(file, free_space) = t
          [FileBlocks(file), FreeSpaceBlocks(free_space)]
        }),
      [],
    )
    |> list.reverse
    |> list.fold(#(0, 0), fn(acc, file) {
      let File(id, block_size) = file
      let #(lower, sum) = acc
      let upper = lower + block_size
      // id * (small gauss(upper - 1) - small gauss(lower - 1))
      let elem = id * { upper * { upper - 1 } - lower * { lower - 1 } } / 2
      #(lower + block_size, sum + elem)
    })
  sum
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
  todo
}
