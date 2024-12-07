use anyhow::anyhow;
use std::{
    collections::HashSet,
    fmt::{Display, Write},
    fs::File,
    io::{BufRead, BufReader},
    path::Path,
};

pub fn main() -> anyhow::Result<()> {
    let state = State::read_initial_from_file(Path::new("resources/day06/input.txt"))?;
    let solution = problem1::simulate(state.clone());
    println!("Problem 1 - Solution: {solution}");
    let solution = problem2::find_additional_obstacle_positions(state);
    println!("Problem 2 - Solution: {solution}");
    Ok(())
}

#[derive(Debug, Clone, PartialEq, Eq)]
enum Tile {
    NotVisited,
    Visited(HashSet<Direction>),
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

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
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
        let content: Vec<Tile> = lines
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
                                Tile::Visited([heading].into())
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
            board: Board {
                height: content.len() / width,
                content,
                width,
            },
            guard,
        })
    }
}

#[derive(Debug, Clone)]
struct Board {
    content: Vec<Tile>,
    width: usize,
    height: usize,
}

impl Display for Board {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let Self {
            content,
            width,
            height,
        } = self;
        for (i, row) in content.chunks(*width).enumerate() {
            for tile in row {
                let c = match tile {
                    Tile::NotVisited => '.',
                    Tile::Visited(_) => 'X',
                    Tile::Obstacle => '#',
                };
                f.write_char(c)?;
            }
            if i < height - 1 {
                f.write_char('\n')?;
            }
        }
        Ok(())
    }
}

impl Board {
    fn get(&self, x: isize, y: isize) -> Option<&Tile> {
        if !self.is_in_bounds(x, y) {
            return None;
        }
        let Self { content, width, .. } = self;
        let index = y as usize * width + x as usize;
        content.get(index)
    }

    fn get_mut(&mut self, x: isize, y: isize) -> Option<&mut Tile> {
        if !self.is_in_bounds(x, y) {
            return None;
        }
        let Self { content, width, .. } = self;
        let index = y as usize * *width + x as usize;
        content.get_mut(index)
    }

    fn is_in_bounds(&self, x: isize, y: isize) -> bool {
        let Self { width, height, .. } = self;
        (0..*width as isize).contains(&x) && (0..*height as isize).contains(&y)
    }

    fn mark_visited(&mut self, x: isize, y: isize, direction: Direction) -> anyhow::Result<bool> {
        if !self.is_in_bounds(x, y) {
            return Err(anyhow!("Out of bounds!"));
        }
        let Self { content, width, .. } = self;
        let index = y as usize * *width + x as usize;
        let does_loop = match &mut content[index] {
            t @ Tile::NotVisited => {
                *t = Tile::Visited([direction].into());
                false
            }
            Tile::Visited(ref mut hash_set) => !hash_set.insert(direction),
            Tile::Obstacle => {
                return Err(anyhow!("Is obstacle!"));
            }
        };
        Ok(does_loop)
    }

    fn put_obstacle(&mut self, x: isize, y: isize) -> anyhow::Result<()> {
        if !self.is_in_bounds(x, y) {
            return Err(anyhow!("Out of bounds!"));
        }
        let Self { content, width, .. } = self;
        let index = y as usize * *width + x as usize;
        content[index] = Tile::Obstacle;
        Ok(())
    }

    fn count_visited(&self) -> usize {
        self.content
            .iter()
            .filter(|t| matches!(t, Tile::Visited(_)))
            .count()
    }

    fn get_all_visited_coordinates(&self) -> Vec<(usize, usize)> {
        let Self { content, width, .. } = self;
        content
            .iter()
            .enumerate()
            .filter_map(|(i, t)| matches!(t, Tile::Visited(_)).then_some(i))
            .map(|i| (i % width, i / width))
            .collect::<Vec<_>>()
    }
}
mod problem1 {
    use crate::{Guard, State, Tile};

    pub fn simulate(state: State) -> usize {
        let State {
            mut board,
            mut guard,
        } = state;
        let mut direction = guard.heading;
        let (mut x_delta, mut y_delta) = direction.get_vector();
        loop {
            let Guard { x, y, .. } = guard;
            let x_next = x + x_delta;
            let y_next = y + y_delta;
            let Some(tile) = board.get(x_next, y_next) else {
                break;
            };

            if *tile == Tile::Obstacle {
                guard.turn_right();
                direction = guard.heading;
                let (x_d, y_d) = direction.get_vector();
                x_delta = x_d;
                y_delta = y_d;
            } else {
                if *tile == Tile::NotVisited {
                    board.mark_visited(x_next, y_next, direction).unwrap();
                }
                guard.move_to(x_next, y_next);
            }
        }
        board.count_visited()
    }
}

mod problem2 {

    use crate::{Guard, State, Tile};
    pub fn find_additional_obstacle_positions(initial_state: State) -> usize {
        let mut state = initial_state.clone();
        let Guard {
            x: x_initial,
            y: y_initial,
            ..
        } = &state.guard;
        let x_initial = *x_initial;
        let y_initial = *y_initial;
        simulate(&mut state);
        let mut visited_coords = state.board.get_all_visited_coordinates();
        visited_coords.retain(|(x, y)| x_initial != (*x as isize) || y_initial != (*y as isize));
        let mut loop_counter = 0;
        for (x, y) in visited_coords {
            let mut state = initial_state.clone();
            state.board.put_obstacle(x as isize, y as isize).unwrap();
            if simulate(&mut state) {
                loop_counter += 1;
            }
        }
        loop_counter
    }

    fn simulate(state: &mut State) -> bool {
        let State {
            ref mut board,
            ref mut guard,
        } = state;
        let mut direction = guard.heading;
        let (mut x_delta, mut y_delta) = direction.get_vector();
        loop {
            let Guard { x, y, .. } = guard;
            let x_next = *x + x_delta;
            let y_next = *y + y_delta;
            let Some(tile) = board.get_mut(x_next, y_next) else {
                break;
            };

            if *tile == Tile::Obstacle {
                guard.turn_right();
                direction = guard.heading;
                let (x_d, y_d) = direction.get_vector();
                x_delta = x_d;
                y_delta = y_d;
            } else {
                if board.mark_visited(x_next, y_next, direction).unwrap() {
                    return true;
                }
                guard.move_to(x_next, y_next);
            }
        }
        false
    }
}

#[cfg(test)]
mod test {
    use crate::{problem1, problem2, State};
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

    #[test]
    fn test_problem2() {
        let solution = problem2::find_additional_obstacle_positions(get_input());
        assert_eq!(solution, 6)
    }
}
