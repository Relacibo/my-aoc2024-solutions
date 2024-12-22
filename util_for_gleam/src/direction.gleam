import gleam/list

pub type Direction {
  North
  NorthEast
  East
  SouthEast
  South
  SouthWest
  West
  NorthWest
}

pub fn to_number_non_diag(dir: Direction) -> Int {
  case dir {
    North -> 0
    East -> 1
    South -> 2
    West -> 3
    _ -> panic as "Direction not supported"
  }
}

pub fn from_number_non_diag(num: Int) -> Direction {
  case num {
    0 -> North
    1 -> East
    2 -> South
    3 -> West
    _ -> panic as "Direction not supported"
  }
}

pub fn iter_non_diag_starting_at(dir: Direction) -> List(Direction) {
  let offset = dir |> to_number_non_diag
  list.range(0, 3)
  |> list.map(fn(i) { from_number_non_diag({ i + offset } % 4) })
}

pub fn iter_non_diag() -> List(Direction) {
  [North, East, South, West]
}

pub fn iter() -> List(Direction) {
  [North, NorthEast, East, SouthEast, South, SouthWest, West, NorthWest]
}

pub fn next_clockwise_non_diag(dir: Direction) -> Direction {
  case dir {
    North -> East
    East -> South
    South -> West
    West -> North
    _ -> panic as "Direction not supported"
  }
}

pub fn next_counterclockwise_non_diag(dir: Direction) -> Direction {
  case dir {
    North -> West
    East -> North
    South -> East
    West -> South
    _ -> panic as "Direction not supported"
  }
}

pub fn opposite(dir: Direction) -> Direction {
  case dir {
    North -> South
    NorthEast -> SouthWest
    East -> West
    SouthEast -> NorthWest
    South -> North
    SouthWest -> NorthEast
    West -> East
    NorthWest -> SouthEast
  }
}
