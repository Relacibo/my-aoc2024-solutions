import day09.{
  type DiskBlocks, type File, File, FileBlocks, FreeSpace, FreeSpaceBlocks,
  FreeSpaceMap, day_number_string, find_free_spaces_solution2, insert_free_space,
  insert_free_space_and_cleanup, read_input, remove_free_space_for_indices,
  solution1, solution2, use_first_free_space,
}
import gleam/dict
import startest.{describe, it}
import startest/expect

pub fn day09_tests() {
  let assert Ok(input) =
    read_input("resources/" <> day_number_string <> "/test_input.txt")
  let assert Ok(input2) =
    read_input("resources/" <> day_number_string <> "/test_input2.txt")
  let assert Ok(input3) =
    read_input("resources/" <> day_number_string <> "/test_input3.txt")
  describe(day_number_string, [
    it("solution 1", fn() {
      solution1(input)
      |> expect.to_equal(1928)
    }),
    describe("solution 2", [
      it("insert_free_space", fn() {
        insert_free_space(dict.new(), [], 1, 2)
        |> expect.to_equal(#([#(1, 2)] |> dict.from_list, [#(2, [1])]))
      }),
      it("insert_free_space2", fn() {
        insert_free_space([#(0, 2)] |> dict.from_list, [#(2, [0])], 1, 2)
        |> expect.to_equal(
          #([#(0, 2), #(1, 2)] |> dict.from_list, [#(2, [0, 1])]),
        )
      }),
      it("insert_free_space3", fn() {
        insert_free_space([#(0, 2)] |> dict.from_list, [#(2, [0])], 1, 1)
        |> expect.to_equal(
          #([#(0, 2), #(1, 1)] |> dict.from_list, [#(1, [1]), #(2, [0])]),
        )
      }),
      it("remove_free_space_for_indices", fn() {
        remove_free_space_for_indices(
          [#(0, 2), #(1, 2)] |> dict.from_list,
          [#(2, [0, 1])],
          [1],
        )
        |> expect.to_equal(#([#(0, 2)] |> dict.from_list, [#(2, [0])], 2))
      }),
      it("remove_free_space_for_indices2", fn() {
        remove_free_space_for_indices(
          [#(0, 2), #(2, 1)] |> dict.from_list,
          [#(1, [2]), #(2, [0])],
          [0],
        )
        |> expect.to_equal(#([#(2, 1)] |> dict.from_list, [#(1, [2])], 2))
      }),
      it("insert_free_space_and_cleanup", fn() {
        insert_free_space_and_cleanup(
          FreeSpaceMap([#(0, 2)] |> dict.from_list, [#(2, [0])]),
          [],
          0,
          2,
        )
        |> expect.to_equal(
          FreeSpaceMap([#(0, 4)] |> dict.from_list, [#(4, [0])]),
        )
      }),
      it("insert_free_space_and_cleanup2", fn() {
        insert_free_space_and_cleanup(
          FreeSpaceMap([#(0, 2)] |> dict.from_list, [#(2, [0])]),
          [1],
          1,
          2,
        )
        |> expect.to_equal(
          FreeSpaceMap([#(0, 2), #(1, 2)] |> dict.from_list, [#(2, [0, 1])]),
        )
      }),
      it("insert_free_space_and_cleanup3", fn() {
        insert_free_space_and_cleanup(
          FreeSpaceMap([#(0, 2), #(2, 1)] |> dict.from_list, [
            #(1, [2]),
            #(2, [0]),
          ]),
          [1],
          0,
          2,
        )
        |> expect.to_equal(
          FreeSpaceMap([#(0, 4), #(2, 1)] |> dict.from_list, [
            #(1, [2]),
            #(4, [0]),
          ]),
        )
      }),
      it("insert_free_space_and_cleanup4", fn() {
        insert_free_space_and_cleanup(
          FreeSpaceMap([#(0, 2), #(2, 1)] |> dict.from_list, [
            #(1, [2]),
            #(2, [0]),
          ]),
          [],
          0,
          2,
        )
        |> expect.to_equal(
          FreeSpaceMap([#(0, 4), #(2, 1)] |> dict.from_list, [
            #(1, [2]),
            #(4, [0]),
          ]),
        )
      }),
      it("insert_free_space_and_cleanup5", fn() {
        insert_free_space_and_cleanup(
          FreeSpaceMap([#(0, 2), #(2, 1), #(3, 1)] |> dict.from_list, [
            #(1, [2, 3]),
            #(2, [0]),
          ]),
          [],
          2,
          2,
        )
        |> expect.to_equal(
          FreeSpaceMap([#(0, 5), #(3, 1)] |> dict.from_list, [
            #(1, [3]),
            #(5, [0]),
          ]),
        )
      }),
      it("insert_free_space_and_cleanup6", fn() {
        insert_free_space_and_cleanup(
          FreeSpaceMap([#(0, 1), #(1, 2), #(2, 1), #(3, 1)] |> dict.from_list, [
            #(1, [0, 2, 3]),
            #(2, [1]),
          ]),
          [1],
          3,
          2,
        )
        |> expect.to_equal(
          FreeSpaceMap([#(0, 1), #(1, 6)] |> dict.from_list, [
            #(1, [0]),
            #(6, [1]),
          ]),
        )
      }),
      it("insert_free_space_and_cleanup7", fn() {
        insert_free_space_and_cleanup(
          FreeSpaceMap([#(0, 3), #(1, 3)] |> dict.from_list, [#(3, [0, 1])]),
          [1],
          0,
          2,
        )
        |> expect.to_equal(
          FreeSpaceMap([#(0, 5), #(1, 3)] |> dict.from_list, [
            #(3, [1]),
            #(5, [0]),
          ]),
        )
      }),
      it("use_first_free_space", fn() {
        use_first_free_space(
          [#(0, 1), #(1, 2), #(2, 1), #(3, 1)] |> dict.from_list,
          [#(1, [0, 2, 3]), #(2, [1])],
          [],
          [1],
          4,
          2,
        )
        |> expect.to_equal(
          Ok(#(
            FreeSpaceMap([#(0, 1), #(1, 4)] |> dict.from_list, [
              #(1, [0]),
              #(4, [1]),
            ]),
            1,
          )),
        )
      }),
      it("find_free_spaces", fn() {
        let rev = [File(2, 3), File(1, 3), File(0, 2)]
        let spaces =
          FreeSpaceMap([#(0, 3), #(1, 3)] |> dict.from_list, [#(3, [0, 1])])
        let files = dict.new()
        find_free_spaces_solution2(rev, spaces, files)
        |> expect.to_equal([
          FileBlocks(File(0, 2)),
          FileBlocks(File(2, 3)),
          FileBlocks(File(1, 3)),
          FreeSpaceBlocks(FreeSpace(6)),
        ])
      }),
      it("solution", fn() {
        solution2(input)
        |> expect.to_equal(2858)
      }),
      it("solutionInput2", fn() {
        solution2(input2)
        |> expect.to_equal(1703)
      }),
      it("solutionInput3", fn() {
        solution2(input3)
        |> expect.to_equal(1703)
      }),
    ]),
  ])
}
