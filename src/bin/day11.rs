use anyhow::anyhow;
use memoize::memoize;
use rayon::iter::{IntoParallelRefIterator, ParallelIterator};
use std::{
    fs::File,
    io::{BufRead, BufReader},
    path::Path,
};

const DAY_NUMBER_STRING: &str = "day11";

pub fn main() -> anyhow::Result<()> {
    let input = Input::read_from_file(Path::new(&format!(
        "resources/{DAY_NUMBER_STRING}/input.txt"
    )))?;
    let solution = solution(input, 75);
    println!("Problem 2 - Solution: {solution}");
    Ok(())
}

#[derive(Debug, Clone, Default)]
pub struct Input(Vec<u64>);

impl Input {
    fn read_from_file(path: &Path) -> anyhow::Result<Self> {
        let file = File::open(path)?;

        let line = BufReader::new(file)
            .lines()
            .take(1)
            .next()
            .ok_or_else(|| anyhow!("Input is empty!"))??;
        let content = line
            .split_whitespace()
            .map(|s| s.parse::<u64>())
            .collect::<Result<Vec<_>, _>>()?;
        Ok(Input(content))
    }
}

pub fn solution(input: Input, iterations: u32) -> u64 {
    let Input(stones) = input;
    if iterations <= 20 {
        return run_algorithm(stones, iterations);
    }
    const SINGLE_THREADED_ITERATIONS_COUNT: u32 = 15;
    let multi_threaded_iteration_count = iterations - SINGLE_THREADED_ITERATIONS_COUNT;
    let stones = run_algorithm_preserving_stack(stones, SINGLE_THREADED_ITERATIONS_COUNT);
    stones
        .par_iter()
        .map(|stone| run_algorithm_single_stone_memoized(*stone, multi_threaded_iteration_count))
        .sum()
}

fn run_algorithm_preserving_stack(stones: Vec<u64>, iterations: u32) -> Vec<u64> {
    let mut stack = stones
        .into_iter()
        .map(|s| (s, iterations))
        .collect::<Vec<_>>();
    let mut stack_res = vec![];
    while let Some((stone, i)) = stack.pop() {
        if i == 0 {
            stack_res.push(stone);
            continue;
        }
        let i = i - 1;
        handle_stone(stone, |s| stack.push((s, i)));
    }
    stack_res.reverse();
    stack_res
}

fn run_algorithm(stones: Vec<u64>, iterations: u32) -> u64 {
    let mut stack = stones
        .into_iter()
        .map(|s| (s, iterations))
        .collect::<Vec<_>>();
    let mut sum = 0;
    while let Some((stone, i)) = stack.pop() {
        if i == 0 {
            sum += 1;
            continue;
        }
        let i = i - 1;
        handle_stone(stone, |s| stack.push((s, i)));
    }
    sum
}

fn run_algorithm_single_stone(stone: u64, iterations: u32) -> u64 {
    let mut stack = vec![(stone, iterations)];
    let mut sum = 0;
    while let Some((stone, i)) = stack.pop() {
        if i == 0 {
            sum += 1;
            continue;
        }
        let i = i - 1;
        handle_stone(stone, |s| stack.push((s, i)))
    }
    sum
}

#[memoize]
fn run_algorithm_single_stone_memoized(stone: u64, iterations: u32) -> u64 {
    if iterations == 0 {
        return 1;
    }
    let i = iterations - 1;
    let mut sum = 0;
    handle_stone(stone, |s| sum += run_algorithm_single_stone_memoized(s, i));
    sum
}

fn handle_stone(stone: u64, mut callback: impl FnMut(u64)) {
    if stone == 0 {
        callback(1);
        return;
    }
    let num_digits = stone.checked_ilog10().unwrap_or(0) + 1;
    if num_digits % 2 == 0 {
        let divisor = 10_u64.pow(num_digits / 2);
        callback(stone / divisor);
        callback(stone % divisor);
        return;
    }
    callback(stone * 2024);
}

#[cfg(test)]
mod test {
    use crate::{run_algorithm_preserving_stack, solution, Input, DAY_NUMBER_STRING};
    use std::{cell::LazyCell, ops::Deref, path::Path};

    thread_local! {
        static INPUT: LazyCell<Input> = LazyCell::new(||Input::read_from_file(Path::new(Path::new(&format!("resources/{DAY_NUMBER_STRING}/test_input.txt")))).unwrap());
    }

    fn get_input() -> Input {
        INPUT.with(|i| i.deref().clone())
    }

    #[test]
    fn test_problem5() {
        let solution = solution(get_input(), 6);
        assert_eq!(solution, 22)
    }

    #[test]
    fn test_preserving_stack() {
        let solution = run_algorithm_preserving_stack(get_input().0, 6);
        assert_eq!(
            solution,
            vec![
                2097446912, 14168, 4048, 2, 0, 2, 4, 40, 48, 2024, 40, 48, 80, 96, 2, 8, 6, 7, 6,
                0, 3, 2
            ]
        )
    }

    #[test]
    fn test_problem1() {
        let solution = solution(get_input(), 25);
        assert_eq!(solution, 55312)
    }
}
