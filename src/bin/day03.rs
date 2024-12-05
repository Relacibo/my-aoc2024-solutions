use std::{fs, path::Path};

use regex::Regex;

pub fn main() -> anyhow::Result<()> {
    let input = fs::read_to_string(Path::new("resources/day03/input.txt"))?;

    let sum_of_products = problem1::solution(&input);
    println!("Problem 1 - Sum of products: {sum_of_products}");
    let sum_of_products = problem2::solution(&input);
    println!("Problem 2 - Sum of products: {sum_of_products}");
    Ok(())
}

mod problem1 {
    use std::cell::LazyCell;

    use regex::Regex;

    thread_local! {
        static REGEX: LazyCell<Regex> = LazyCell::new(||Regex::new(r"mul\((?<a>\d+),(?<b>\d+)\)").unwrap());
    }

    pub fn solution(input: &str) -> i32 {
        REGEX.with(|regex| {
            regex
                .captures_iter(input)
                .map(|c| {
                    [&c["a"], &c["b"]]
                        .into_iter()
                        .map(str::parse::<i32>)
                        .collect::<Result<Vec<_>, _>>()
                        .ok()
                        .into_iter()
                        .flatten()
                        .product::<i32>()
                })
                .sum()
        })
    }

    #[cfg(test)]
    mod test {
        use super::solution;

        static TEST_INPUT: &str =
            "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))";

        #[test]
        fn test_problem1() {
            let solution = solution(TEST_INPUT);
            assert_eq!(solution, 161);
        }
    }
}

mod problem2 {
    use std::iter;

    use crate::problem1;

    pub fn solution(input: &str) -> i32 {
        let mut instructions = input
            .match_indices("do()")
            .map(|(i, _)| (i + 4, true))
            .chain(input.match_indices("don't()").map(|(i, _)| (i, false)))
            .collect::<Vec<_>>();
        instructions.sort_by_key(|o| o.0);
        let mut state = true;
        let v = [0]
            .into_iter()
            .chain(instructions.into_iter().filter_map(|(i, instr)| {
                if instr != state {
                    state = instr;
                    Some(i)
                } else {
                    None
                }
            }))
            .collect::<Vec<_>>();
        let filtered = v
            .chunks(2)
            .map(|c| match c {
                [start, end] => &input[*start..*end],
                [start] => &input[*start..],
                _ => unreachable!(),
            })
            .collect::<String>();
        problem1::solution(&filtered)
    }

    #[cfg(test)]
    mod test {
        use super::solution;

        static TEST_INPUT: &str =
            "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))";

        #[test]
        fn test_problem1() {
            let solution = solution(TEST_INPUT);
            assert_eq!(solution, 48);
        }
    }
}
