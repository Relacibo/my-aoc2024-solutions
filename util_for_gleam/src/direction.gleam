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
