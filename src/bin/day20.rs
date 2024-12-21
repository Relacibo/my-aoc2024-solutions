use std::{
    fs::File,
    io::{BufRead, BufReader},
    path::Path,
};

use anyhow::anyhow;

const DAY_NUMBER_STRING: &str = "day20";

pub fn main() -> anyhow::Result<()> {
    let input = Input::read_from_file(Path::new(&format!(
        "resources/{DAY_NUMBER_STRING}/input.txt"
    )))?;
    let solution = problem1::solution(&input);
    // println!("Problem 1 - Solution: {solution}");
    let solution = problem2::solution(input);
    // println!("Problem 2 - Solution: {solution}");
    Ok(())
}

#[derive(Debug, Clone, Copy)]
enum Tile {
    Visited { step: u32 },
    NotVisited,
    Wall,
}

mod problem1 {
    use crate::Input;

    pub fn solution(input: &Input) -> ! {
        // let Input {} = input;
        todo!()
    }
}

mod problem2 {
    use crate::Input;

    pub fn solution(input: Input) -> ! {
        // let Input {} = input;
        todo!()
    }
}

#[cfg(test)]
mod test {
    use crate::{problem1, problem2, Input, DAY_NUMBER_STRING};
    use std::{cell::LazyCell, ops::Deref, path::Path};

    thread_local! {
        static INPUT: LazyCell<Input> = LazyCell::new(||Input::read_from_file(Path::new(Path::new(&format!("resources/{DAY_NUMBER_STRING}/test_input.txt")))).unwrap());
    }

    fn get_input() -> Input {
        INPUT.with(|i| i.deref().clone())
    }

    #[test]
    fn test_problem1() {
        let solution = problem1::solution(&get_input());
        // assert_eq!(solution, 0)
    }

    #[test]
    fn test_problem2() {
        let solution = problem2::solution(get_input());
        // assert_eq!(solution, 0)
    }
}

#[derive(Debug, Clone, Default)]
pub struct Input {
    race_track: grid::Grid<Tile>,
    start: (usize, usize),
    end: (usize, usize),
}

impl Input {
    fn read_from_file(path: &Path) -> anyhow::Result<Self> {
        let file = File::open(path)?;
        let mut start = None;
        let mut end = None;
        let lines = BufReader::new(file)
            .lines()
            .filter_map(|l| {
                let l = l.ok()?;
                (!l.is_empty()).then_some(l)
            })
            .enumerate()
            .map(|(y, l)| {
                l.chars()
                    .enumerate()
                    .filter_map(|(x, c)| match c {
                        '#' => Some(Tile::Wall),
                        '.' => Some(Tile::NotVisited),
                        'S' => {
                            start = Some((x, y));
                            None
                        }
                        'E' => {
                            end = Some((x, y));
                            None
                        }
                        _ => None,
                    })
                    .collect::<Vec<_>>()
            })
            .collect::<Vec<_>>();
        let width = lines[0].len();
        let start = start.unwrap();
        let end = end.unwrap();

        let race_track = grid::Grid::from_vec(lines.into_iter().flatten().collect(), width);

        Ok(Self {
            race_track,
            start,
            end,
        })
    }
}
