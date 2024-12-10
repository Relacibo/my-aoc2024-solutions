import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub const day_number_string = "y2023day02"

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

fn is_game_possible(game: Game) -> Bool {
  let Game(_, game_parts) = game
  game_parts
  |> list.all(fn(gp) {
    let GamePart(red, blue, green) = gp
    red <= 12 && green <= 13 && blue <= 14
  })
}

pub fn solution1(input: Input) -> Int {
  let Input(games) = input
  games |> list.filter(is_game_possible) |> list.map(fn(t) { t.id }) |> int.sum
}

pub fn solution2(input: Input) -> Int {
  let Input(games) = input
  games
  |> list.map(fn(game) {
    let Game(_, game_parts) = game
    let #(r, b, g) =
      game_parts
      |> list.fold(#(0, 0, 0), fn(acc, gp) {
        let #(r, b, g) = acc
        let GamePart(red, blue, green) = gp
        let red = int.max(r, red)
        let blue = int.max(b, blue)
        let green = int.max(g, green)
        #(red, blue, green)
      })
    r * b * g
  })
  |> int.sum
}

pub type Input {
  Input(List(Game))
}

pub type Game {
  Game(id: Int, game_parts: List(GamePart))
}

pub type GamePart {
  GamePart(red: Int, blue: Int, green: Int)
}

pub fn read_input(path: String) -> Result(Input, String) {
  use content <- result.try(
    simplifile.read(path)
    |> result.map_error(fn(_) { "Could not read file" }),
  )
  content
  |> string.split("\n")
  |> list.filter(fn(s) { !string.is_empty(s) })
  |> list.map(fn(row) {
    let assert [head, tail] = row |> string.split(":")
    let assert Ok(id) =
      head |> string.to_graphemes |> list.drop(5) |> string.concat |> int.parse
    let game_parts =
      tail
      |> string.split(";")
      |> list.map(fn(p) {
        p
        |> string.split(",")
        |> list.fold(GamePart(0, 0, 0), fn(acc, c) {
          let GamePart(red, blue, green) = acc
          let assert [num, col] = c |> string.trim_start() |> string.split(" ")
          let assert Ok(num) = num |> int.parse
          case col {
            "red" -> GamePart(num, blue, green)
            "blue" -> GamePart(red, num, green)
            "green" -> GamePart(red, blue, num)
            _ -> {
              panic
            }
          }
        })
      })
    Game(id, game_parts)
  })
  |> Input
  |> Ok
}
