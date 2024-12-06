use anyhow::anyhow;
use std::{
    fmt::{Display, Write},
    fs::File,
    io::{BufRead, BufReader},
    path::Path,
};

pub fn main() -> anyhow::Result<()> {
    let state = State::read_initial_from_file(Path::new("resources/day06/input.txt"))?;
    let solution = problem1::simulate(state);
    println!("Problem 1 - Solution: {solution}");
    // let solution = problem2::solution(input);
    // println!("Problem 2 - Solution: {solution}");
    Ok(())
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Tile {
    NotVisited,
    Visited,
    Obstacle,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
struct Guard {
    x: isize,
    y: isize,
    heading: Direction,
}

impl Guard {
    fn turn_right(&mut self) {
        self.heading = self.heading.turn_right()
    }

    fn move_to(&mut self, x: isize, y: isize) {
        self.x = x;
        self.y = y;
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
#[repr(u32)]
enum Direction {
    North,
    East,
    South,
    West,
}

impl Direction {
    fn turn_right(self) -> Direction {
        use Direction::*;
        match self {
            North => East,
            East => South,
            South => West,
            West => North,
        }
    }
    fn get_vector(&self) -> (isize, isize) {
        use Direction::*;
        match self {
            North => (0, -1),
            East => (1, 0),
            South => (0, 1),
            West => (-1, 0),
        }
    }
}

#[derive(Debug, Clone)]
struct Board {
    content: Vec<Tile>,
    width: usize,
}

impl Display for Board {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let Self { content, width } = self;
        let len = content.len() / width;
        for (i, row) in content.chunks(*width).enumerate() {
            for tile in row {
                let c = match tile {
                    Tile::NotVisited => '.',
                    Tile::Visited => 'X',
                    Tile::Obstacle => '#',
                };
                f.write_char(c)?;
            }
            if i < len - 1 {
                f.write_char('\n')?;
            }
        }
        Ok(())
    }
}

#[derive(Debug, Clone)]
struct State {
    board: Board,
    guard: Guard,
}

impl State {
    fn read_initial_from_file(path: &Path) -> anyhow::Result<Self> {
        let file = File::open(path)?;
        let lines = BufReader::new(file).lines();
        let mut width: Option<usize> = None;
        let mut guard: Option<Guard> = None;
        let content = lines
            .enumerate()
            .map(|(y, line)| {
                let row = line?
                    .chars()
                    .enumerate()
                    .map(|(x, c)| {
                        let res = match c {
                            '.' => Tile::NotVisited,
                            '^' | '>' | 'v' | '<' => {
                                let heading = match c {
                                    '^' => Direction::North,
                                    '>' => Direction::East,
                                    'v' => Direction::South,
                                    '<' => Direction::West,
                                    _ => unreachable!(),
                                };
                                guard = Some(Guard {
                                    heading,
                                    x: x as isize,
                                    y: y as isize,
                                });
                                Tile::Visited
                            }
                            '#' => Tile::Obstacle,
                            ch => return Err(anyhow!("Symbol not supported in input: {ch}")),
                        };
                        Ok(res)
                    })
                    .collect::<anyhow::Result<Vec<_>>>()?;
                let len = row.len();
                if let Some(c) = width {
                    if c != len {
                        return Err(anyhow!("Tile count of row deviates!"));
                    }
                } else {
                    width = Some(len);
                }
                Ok(row)
            })
            .collect::<anyhow::Result<Vec<_>>>()?
            .into_iter()
            .flatten()
            .collect();
        let Some(width) = width else {
            return Err(anyhow!("Unexpected!"));
        };
        let Some(guard) = guard else {
            return Err(anyhow!("Guard not found!"));
        };
        Ok(Self {
            board: Board { content, width },
            guard,
        })
    }
}

impl Board {
    fn get(&self, x: isize, y: isize) -> Option<&Tile> {
        let Self { content, width, .. } = self;
        if x < 0 || y < 0 {
            return None;
        }
        let index = y as usize * width + x as usize;
        content.get(index)
    }

    fn mark_visited(&mut self, x: isize, y: isize) -> anyhow::Result<()> {
        let Self { content, width, .. } = self;
        if x < 0 || y < 0 {
            return Err(anyhow!("Out of bounds!"));
        }
        let index = y as usize * *width + x as usize;
        if index > content.len() {
            return Err(anyhow!("Out of bounds!"));
        }
        content[index] = Tile::Visited;
        Ok(())
    }

    fn count_visited(&self) -> usize {
        self.content.iter().filter(|t| **t == Tile::Visited).count()
    }
}
mod problem1 {
    use crate::{Guard, State, Tile};

    pub fn simulate(state: State) -> usize {
        let State {
            mut board,
            mut guard,
        } = state;
        let (mut x_delta, mut y_delta) = guard.heading.get_vector();
        loop {
            let Guard { x, y, .. } = guard;
            let x_next = x + x_delta;
            let y_next = y + y_delta;
            let Some(tile) = board.get(x_next, y_next) else {
                break;
            };

            if *tile == Tile::Obstacle {
                guard.turn_right();
                let (x_d, y_d) = guard.heading.get_vector();
                x_delta = x_d;
                y_delta = y_d;
            } else {
                if *tile == Tile::NotVisited {
                    board
                        .mark_visited(x_next, y_next)
                        .expect("Unexpected! Out of bounds!")
                }
                guard.move_to(x_next, y_next);
            }
        }
        board.count_visited()
    }
}

#[cfg(test)]
mod test {
    use crate::{problem1, State};
    use std::{cell::LazyCell, ops::Deref, path::Path};

    thread_local! {
        static INPUT: LazyCell<State> = LazyCell::new(||State::read_initial_from_file(Path::new("resources/day06/test_input.txt")).unwrap());
    }

    fn get_input() -> State {
        INPUT.with(|i| i.deref().clone())
    }

    #[test]
    fn test_problem1() {
        let solution = problem1::simulate(get_input());
        assert_eq!(solution, 41)
    }

    // #[test]
    // fn test_problem2() {
    //     let solution = problem2::solution(get_input());
    //     assert_eq!(solution, 123)
    // }
}
