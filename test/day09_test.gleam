import day09.{
  type DiskBlocks, type File, File, FileBlocks, FreeSpace, FreeSpaceBlocks,
  day_number_string, find_free_spaces_solution2, insert_free_space,
  insert_gap_free_space, read_input, solution1, solution2, use_first_free_space,
}
import gleam/dict
import startest.{describe, it}
import startest/expect

pub fn day09_tests() {
  let assert Ok(input) =
    read_input("resources/" <> day_number_string <> "/test_input.txt")
  describe(day_number_string, [
    it("solution 1", fn() {
      solution1(input)
      |> expect.to_equal(1928)
    }),
    describe("solution 2", [
      // it("insert_free_space", fn() {
      //   insert_free_space([], 1, 2)
      //   |> expect.to_equal([#(2, [1])])
      // }),
      // it("insert_free_space2", fn() {
      //   insert_free_space([#(2, [0])], 1, 2)
      //   |> expect.to_equal([#(2, [0, 1])])
      // }),
      // it("insert_free_space3", fn() {
      //   insert_free_space([#(2, [0])], 1, 1)
      //   |> expect.to_equal([#(1, [1]), #(2, [0])])
      // }),
      // it("insert_gap_free_space", fn() {
      //   insert_gap_free_space([#(2, [0])], [], 1, 2)
      //   |> expect.to_equal([#(4, [0])])
      // }),
      // it("insert_gap_free_space2", fn() {
      //   insert_gap_free_space([#(2, [0])], [1], 1, 2)
      //   |> expect.to_equal([#(2, [0, 1])])
      // }),
      // it("insert_gap_free_space3", fn() {
      //   insert_gap_free_space([#(1, [2]), #(2, [0])], [1], 1, 2)
      //   |> expect.to_equal([#(2, [0]), #(3, [1])])
      // }),
      // it("insert_gap_free_space4", fn() {
      //   insert_gap_free_space([#(1, [2]), #(2, [0])], [], 1, 2)
      //   |> expect.to_equal([#(5, [0])])
      // }),
      // it("insert_gap_free_space5", fn() {
      //   insert_gap_free_space([#(1, [2, 3]), #(2, [0])], [], 1, 2)
      //   |> expect.to_equal([#(1, [3]), #(5, [0])])
      // }),
      // it("insert_gap_free_space6", fn() {
      //   insert_gap_free_space([#(1, [0, 2, 3]), #(2, [1])], [1], 4, 2)
      //   |> expect.to_equal([#(1, [0]), #(6, [1])])
      // }),
      // it("insert_gap_free_space7", fn() {
      //   insert_gap_free_space([#(3, [0]), #(3, [1])], [1], 1, 2)
      //   |> expect.to_equal([#(3, [0]), #(5, [1])])
      // }),
      // it("use_first_free_space", fn() {
      //   use_first_free_space([#(1, [0, 2, 3]), #(2, [1])], [], [1], 4, 2)
      //   |> expect.to_equal(Ok(#([#(1, [0]), #(4, [1])], 1)))
      // }),
      // it("find_free_spaces", fn() {
      //   let rev = [File(2, 3), File(1, 3), File(0, 2)]
      //   let spaces = [#(3, [0]), #(3, [1])]
      //   let files = dict.new()
      //   find_free_spaces_solution2(rev, spaces, files)
      //   |> expect.to_equal([
      //     FileBlocks(File(0, 2)),
      //     FileBlocks(File(2, 3)),
      //     FileBlocks(File(1, 3)),
      //     FreeSpaceBlocks(FreeSpace(6)),
      //   ])
      // }),
      it("solution", fn() {
        solution2(input)
        |> expect.to_equal(2858)
      }),
    ]),
  ])
}
