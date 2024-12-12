import direction.{
  type Direction, East, North, NorthEast, NorthWest, South, SouthEast, SouthWest,
  West,
}

pub type Coords {
  Coords(x: Int, y: Int)
}

pub fn add(a: Coords, b: Coords) -> Coords {
  let Coords(x1, y1) = a
  let Coords(x2, y2) = b
  Coords(x1 + x2, y1 + y2)
}

pub fn multiply_with_scalar(a: Coords, s: Int) -> Coords {
  let Coords(x1, y1) = a
  Coords(x1 * s, y1 * s)
}

pub fn from_direction(direction: Direction) -> Coords {
  case direction {
    North -> Coords(0, -1)
    NorthEast -> Coords(1, -1)
    East -> Coords(1, 0)
    SouthEast -> Coords(1, 1)
    South -> Coords(0, 1)
    SouthWest -> Coords(-1, 1)
    West -> Coords(-1, 0)
    NorthWest -> Coords(-1, -1)
  }
}

pub fn move_in_direction(coords: Coords, direction: Direction) -> Coords {
  coords |> add(direction |> from_direction)
}
