use std::{
    fs::File,
    io::{BufRead, BufReader},
    path::Path,
};

use anyhow::anyhow;

const DAY_NUMBER_STRING: &str = "${DAY_NUMBER_STRING}";

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

#[derive(Debug, Clone, Default)]
pub struct Input {}

impl Input {
    fn read_from_file(path: &Path) -> anyhow::Result<Self> {
        let file = File::open(path)?;
        let lines = BufReader::new(file).lines();

        Ok(Self {})
    }
}

mod problem1 {
    use crate::Input;

    pub fn solution(input: &Input) -> ! {
        let Input {} = input;
        todo!()
    }
}

mod problem2 {
    use crate::Input;

    pub fn solution(input: Input) -> ! {
        let Input {} = input;
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
