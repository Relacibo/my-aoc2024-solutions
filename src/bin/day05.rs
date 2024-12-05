use anyhow::anyhow;
use std::{
    collections::HashMap,
    fs::File,
    io::{BufRead, BufReader},
    path::Path,
};

pub fn main() -> anyhow::Result<()> {
    let input = Input::read_from_file(Path::new("resources/day05/input.txt"))?;
    let solution = problem1::solution(&input);
    println!("Problem 1 - Solution: {solution}");
    let solution = problem2::solution(&input);
    println!("Problem 2 - Solution: {solution}");
    Ok(())
}

#[derive(Debug, Clone, Default)]
struct Input {
    before: HashMap<i32, Vec<i32>>,
    updates: Vec<Vec<i32>>,
}

impl Input {
    fn read_from_file(path: &Path) -> anyhow::Result<Self> {
        let file = File::open(path).unwrap();
        let mut lines = BufReader::new(file).lines();
        let mut before: HashMap<i32, Vec<i32>> = HashMap::new();
        let mut updates: Vec<Vec<i32>> = Vec::new();
        while let Some(Ok(line)) = lines.next() {
            if line.is_empty() {
                break;
            }
            let &[a, b] = &line.split("|").collect::<Vec<_>>()[..] else {
                return Err(anyhow!("Input broken!"));
            };
            let a = a.parse::<i32>()?;
            let b = b.parse::<i32>()?;
            before
                .entry(a)
                .and_modify(|e| {
                    e.push(b);
                })
                .or_insert_with(|| vec![b]);
        }
        while let Some(Ok(line)) = lines.next() {
            if line.is_empty() {
                break;
            }
            let v = line
                .split(",")
                .map(str::parse::<i32>)
                .collect::<Result<Vec<_>, _>>()?;
            updates.push(v);
        }
        Ok(Self { before, updates })
    }
}

mod problem1 {
    use std::collections::HashMap;

    use crate::Input;

    pub fn solution(input: &Input) -> i32 {
        let Input { before, updates } = input;
        updates
            .iter()
            .filter_map(|u| is_update_order_correct(before, u).then_some(u[u.len() / 2]))
            .sum()
    }
    pub fn is_update_order_correct(before: &HashMap<i32, Vec<i32>>, update: &[i32]) -> bool {
        update
            .iter()
            .enumerate()
            .map(|(i, page)| {
                let b = before
                    .get(page)
                    .into_iter()
                    .flatten()
                    .copied()
                    .collect::<Vec<_>>();
                (i, b)
            })
            .all(|(i, before)| !*&update[..i].iter().any(|b| before.contains(b)))
    }

    #[cfg(test)]
    mod test {
        use std::path::Path;

        use crate::Input;

        #[test]
        fn test_problem1() {
            let input = Input::read_from_file(Path::new("resources/day05/test_input.txt")).unwrap();
            let solution = super::solution(&input);
            assert_eq!(solution, 143)
        }
    }
}

mod problem2 {
    use std::collections::HashMap;

    use crate::{problem1::is_update_order_correct, Input};

    pub fn solution(input: &Input) -> i32 {
        let Input { before, updates } = input;
        updates
            .iter()
            .filter(|u| !is_update_order_correct(before, u))
            .map(|u| fix_update_order(before, u.clone()))
            .map(|u| u[u.len() / 2])
            .sum()
    }

    fn fix_update_order(before: &HashMap<i32, Vec<i32>>, mut update: Vec<i32>) -> Vec<i32> {
        let mut i = 0_usize;
        while i < update.len() {
            let page = update[i];
            let b = before
                .get(&page)
                .into_iter()
                .flatten()
                .copied()
                .collect::<Vec<_>>();
            if let Some(pos) = &update[..i].iter().position(|p| b.contains(p)) {
                update[*pos..=i].rotate_right(1);
                i = *pos;
            } else {
                i += 1;
            }
        }
        update
    }
    #[cfg(test)]
    mod test {
        use std::path::Path;

        use crate::Input;

        #[test]
        fn test_problem2() {
            let input = Input::read_from_file(Path::new("resources/day05/test_input.txt")).unwrap();
            let solution = super::solution(&input);
            assert_eq!(solution, 123)
        }
    }
}
