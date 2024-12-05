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
    let solution = problem2::solution(input);
    println!("Problem 2 - Solution: {solution}");
    Ok(())
}

#[derive(Debug, Clone, Default)]
struct Input {
    update_dependents_map: HashMap<i32, Vec<i32>>,
    updates: Vec<Vec<i32>>,
}

impl Input {
    fn read_from_file(path: &Path) -> anyhow::Result<Self> {
        let file = File::open(path).unwrap();
        let mut lines = BufReader::new(file).lines();
        let mut update_dependents_map: HashMap<i32, Vec<i32>> = HashMap::new();
        let mut updates: Vec<Vec<i32>> = Vec::new();
        while let Some(Ok(line)) = lines.next() {
            if line.is_empty() {
                break;
            }
            let &[a, b] = &line
                .split("|")
                .map(str::parse::<i32>)
                .collect::<Result<Vec<_>, _>>()?[..]
            else {
                return Err(anyhow!("Input broken!"));
            };
            update_dependents_map
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
        Ok(Self {
            update_dependents_map,
            updates,
        })
    }
}

mod problem1 {
    use std::collections::HashMap;

    use crate::Input;

    pub fn solution(input: &Input) -> i32 {
        let Input {
            update_dependents_map,
            updates,
        } = input;
        updates
            .iter()
            .filter_map(|u| {
                is_update_order_correct(update_dependents_map, u).then_some(u[u.len() / 2])
            })
            .sum()
    }
    pub fn is_update_order_correct(
        update_dependents_map: &HashMap<i32, Vec<i32>>,
        update: &[i32],
    ) -> bool {
        update
            .iter()
            .enumerate()
            .filter_map(|(i, page)| update_dependents_map.get(page).map(|b| (i, b)))
            .all(|(i, dependents)| *&update[..i].iter().all(|page| !dependents.contains(page)))
    }
}

mod problem2 {
    use std::collections::HashMap;

    use crate::Input;

    pub fn solution(input: Input) -> i32 {
        let Input {
            update_dependents_map,
            updates,
        } = input;
        updates
            .into_iter()
            .filter_map(|mut u| {
                fix_update_order(&update_dependents_map, &mut u).then_some(u[u.len() / 2])
            })
            .sum()
    }

    fn fix_update_order(
        update_dependents_map: &HashMap<i32, Vec<i32>>,
        update: &mut Vec<i32>,
    ) -> bool {
        let mut was_changed = false;
        for i in 0..update.len() {
            let Some(dependents) = update_dependents_map.get(&update[i]) else {
                continue;
            };
            let violation = &update[..i]
                .iter()
                .position(|page| dependents.contains(page));
            if let Some(pos) = violation {
                was_changed = true;
                update[*pos..=i].rotate_right(1);
            }
        }
        was_changed
    }
}

#[cfg(test)]
mod test {
    use crate::{problem1, problem2, Input};
    use std::{cell::LazyCell, ops::Deref, path::Path};

    thread_local! {
        static INPUT: LazyCell<Input> = LazyCell::new(||Input::read_from_file(Path::new("resources/day05/test_input.txt")).unwrap());
    }

    fn get_input() -> Input {
        INPUT.with(|i| i.deref().clone())
    }

    #[test]
    fn test_problem1() {
        let solution = problem1::solution(&get_input());
        assert_eq!(solution, 143)
    }

    #[test]
    fn test_problem2() {
        let solution = problem2::solution(get_input());
        assert_eq!(solution, 123)
    }
}
