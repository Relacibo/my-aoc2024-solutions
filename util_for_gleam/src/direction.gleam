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
