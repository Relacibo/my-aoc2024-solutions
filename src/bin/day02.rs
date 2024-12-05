use std::{
    fs::File,
    io::{BufRead, BufReader},
};

fn main() {
    let file = File::open("resources/day02/input.txt").unwrap();
    let input: Vec<_> = BufReader::new(file)
        .lines()
        .flatten()
        .map(|line| {
            line.split_whitespace()
                .flat_map(str::parse::<i32>)
                .collect::<Vec<_>>()
        })
        .collect();
    let count = problem1::count_safe(&input);
    println!("Problem 1 - safe count: {count}");
    let count = problem2::count_safe(&input);
    println!("Problem 2 - safe count: {count}")
}

mod problem1 {
    pub fn count_safe(input: &[Vec<i32>]) -> i32 {
        input.iter().filter(|v| is_safe(v)).count() as i32
    }

    pub fn is_safe(i: &[i32]) -> bool {
        let differences = i
            .windows(2)
            .map(|w| {
                let [a, b] = w else {
                    panic!();
                };
                b - a
            })
            .collect::<Vec<_>>();
        if !differences
            .iter()
            .copied()
            .map(i32::abs)
            .all(|i| i >= 1 && i <= 3)
        {
            return false;
        }
        let mut iter = differences.iter();
        let Some(first) = iter.next() else {
            return false;
        };
        let first = first.signum();
        iter.all(|n| n.signum() == first)
    }
}

mod problem2 {
    use crate::problem1;

    pub fn count_safe(input: &[Vec<i32>]) -> i32 {
        input
            .iter()
            .filter(|v| {
                let is_safe = is_safe(v);
                dbg!(is_safe);
                is_safe
            })
            .count() as i32
    }

    pub fn is_safe(param: &[i32]) -> bool {
        let differences = param
            .windows(2)
            .map(|w| {
                let [a, b] = w else {
                    panic!();
                };
                b - a
            })
            .collect::<Vec<_>>();
        let difference_violations = differences
            .iter()
            .copied()
            .map(i32::abs)
            .enumerate()
            .filter_map(|(i, num)| (num < 1 || num > 3).then_some(i))
            .collect::<Vec<_>>();
        if difference_violations.len() > 2 {
            return false;
        }
        let (negative, positive) = differences
            .iter()
            .enumerate()
            .partition::<Vec<(_, &i32)>, _>(|(_, num)| num.signum() == -1);

        let negative = negative.into_iter().map(|(i, _)| i).collect::<Vec<_>>();
        let positive = positive.into_iter().map(|(i, _)| i).collect::<Vec<_>>();

        if negative.len() > 2 && positive.len() > 2 {
            return false;
        }

        if difference_violations.len() == 0 && (negative.len() == 0 || positive.len() == 0) {
            return true;
        }

        if difference_violations.len() > 0 {
            dbg!(&param);
            dbg!(&difference_violations);
            dbg!(&negative);
            dbg!(&positive);
            return can_violation_be_fixed(param, &difference_violations);
        }

        if negative.len() <= 2 {
            dbg!(&param);
            dbg!(&negative);
            if can_violation_be_fixed(param, &negative) {
                return true;
            }
        }

        if positive.len() <= 2 {
            dbg!(&param);
            dbg!(&positive);
            if can_violation_be_fixed(param, &positive) {
                return true;
            }
        }
        dbg!(&param);

        return false;
    }

    fn can_violation_be_fixed(param: &[i32], violations: &[usize]) -> bool {
        match violations {
            &[i1] => {
                let mut v = param.to_vec();
                v.remove(i1);
                if problem1::is_safe(&v) {
                    return true;
                }
                let mut v = param.to_vec();
                v.remove(i1 + 1);
                return problem1::is_safe(&v);
            }
            &[i1, i2] => {
                if i2 != i1 + 1 {
                    return false;
                }
                let mut v = param.to_vec();
                v.remove(i1 + 1);
                return problem1::is_safe(&v);
            }
            _ => panic!(),
        }
    }
}
