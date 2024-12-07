use std::{
    fs::File,
    io::{BufRead, BufReader},
    path::Path,
};

use anyhow::anyhow;

const DAY_NUMBER_STRING: &'static str = "day07";

pub fn main() -> anyhow::Result<()> {
    let input = Input::read_from_file(Path::new(&format!(
        "resources/{DAY_NUMBER_STRING}/input.txt"
    )))?;
    let solution = problem1::solution(&input);
    println!("Problem 1 - Solution: {solution}");
    // let solution = problem2::solution(input);
    // println!("Problem 2 - Solution: {solution}");
    Ok(())
}

#[derive(Debug, Clone)]
struct Input {
    rows: Vec<InputRow>,
}

#[derive(Debug, Clone)]
struct InputRow {
    result: i64,
    elements: Vec<i32>,
}

impl Input {
    fn read_from_file(path: &Path) -> anyhow::Result<Self> {
        let file = File::open(path)?;
        let rows = BufReader::new(file)
            .lines()
            .map(|line| -> anyhow::Result<_> {
                let line = line?;
                let [result, rest] = line.split(": ").take(2).collect::<Vec<_>>()[..] else {
                    return Err(anyhow!("Wrong line format!"));
                };
                let result = result.parse()?;
                let elements = rest
                    .split_whitespace()
                    .map(|elem| elem.parse::<i32>())
                    .collect::<Result<Vec<_>, _>>()?;
                Ok(InputRow { result, elements })
            })
            .collect::<Result<Vec<InputRow>, _>>()?;
        Ok(Self { rows })
    }
}

mod problem1 {
    use std::ops::{Add, Mul};

    use crate::{Input, InputRow};

    #[derive(Debug, Clone)]
    struct IntermediateResult<'a> {
        wanted_result: i64,
        accumulator: i64,
        elements_remaining: &'a [i32],
    }

    pub fn solution(input: &Input) -> i64 {
        let Input { rows } = input;
        let mut sum = 0;
        for row in rows {
            if check_row(row) {
                sum += row.result;
            }
        }
        sum
    }

    fn check_row(row: &InputRow) -> bool {
        let InputRow { result, elements } = row;
        let [first, rest @ ..] = &elements[..] else {
            return false;
        };
        let mut stack: Vec<IntermediateResult> = vec![IntermediateResult {
            wanted_result: *result,
            accumulator: *first as i64,
            elements_remaining: rest,
        }];
        // dfs
        while let Some(elem) = stack.pop() {
            let IntermediateResult {
                wanted_result,
                accumulator,
                elements_remaining,
            } = elem;
            match elements_remaining {
                [first] => {
                    if [Mul::mul, Add::add]
                        .into_iter()
                        .map(|op| op(accumulator, *first as i64))
                        .any(|res| res == wanted_result)
                    {
                        return true;
                    }
                }
                [first, elements_remaining @ ..] => [Mul::mul, Add::add]
                    .into_iter()
                    .map(|op| op(accumulator, *first as i64))
                    .filter(|res| *res <= wanted_result)
                    .for_each(|accumulator| {
                        stack.push(IntermediateResult {
                            wanted_result,
                            accumulator,
                            elements_remaining,
                        })
                    }),
                _ => unreachable!(),
            }
        }
        false
    }
}

mod problem2 {
    use crate::Input;

    pub fn solution(input: Input) -> ! {
        let Input { rows } = input;
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
        assert_eq!(solution, 3749)
    }

    #[test]
    fn test_problem2() {
        let solution = problem2::solution(get_input());
        // assert_eq!(solution, 0)
    }
}
