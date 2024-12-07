use std::{
    fs::File,
    io::{BufRead, BufReader},
};

pub fn main() {
    let file = File::open("resources/day04/input.txt").unwrap();
    let input = BufReader::new(file)
        .lines()
        .map(|line| line.unwrap().chars().collect::<Vec<_>>())
        .collect::<Vec<_>>();
    let sum = problem1::find(input.clone());
    println!("Problem 1 - sum: {sum}");

    let sum2 = problem2::find(input);
    println!("Problem 2 - sum: {sum2}");
}

mod problem1 {
    use std::iter;
    const WORD: &str = "XMAS";
    const WORD_REV: &str = "SAMX";
    const WORD_SIZE: usize = 4;
    pub fn find(input: Vec<Vec<char>>) -> usize {
        let height = input.len();
        let width = input[0].len();
        horizontal(width, height)
            .chain(vertical(width, height))
            .chain(diagonal_down(width, height))
            .chain(diagonal_up(width, height))
            .map(|iter| {
                let s = iter.map(|(x, y)| input[y][x]).collect::<String>();
                let occurences: usize = s.match_indices(WORD).count();
                let occurences_rev: usize = s.match_indices(WORD_REV).count();
                occurences + occurences_rev
            })
            .sum()
    }

    fn horizontal(
        width: usize,
        height: usize,
    ) -> Box<dyn Iterator<Item = Box<dyn Iterator<Item = (usize, usize)>>>> {
        Box::new((0..height).map(move |y| {
            Box::new((0..width).map(move |x| (x, y))) as Box<dyn Iterator<Item = (usize, usize)>>
        }))
    }

    fn vertical(
        width: usize,
        height: usize,
    ) -> Box<dyn Iterator<Item = Box<dyn Iterator<Item = (usize, usize)>>>> {
        Box::new((0..width).map(move |x| {
            Box::new((0..height).map(move |y| (x, y))) as Box<dyn Iterator<Item = (usize, usize)>>
        }))
    }

    fn diagonal_down(
        width: usize,
        height: usize,
    ) -> Box<dyn Iterator<Item = Box<dyn Iterator<Item = (usize, usize)>>>> {
        let mut x_start = 0;
        let mut y_start = height - WORD_SIZE;
        Box::new(iter::from_fn(move || {
            if x_start + WORD_SIZE > width {
                return None;
            }
            let mut x = x_start;
            let mut y = y_start;
            let ret = Box::new(iter::from_fn(move || {
                if x >= width || y >= height {
                    return None;
                }
                let r = (x, y);
                x += 1;
                y += 1;
                Some(r)
            })) as Box<dyn Iterator<Item = (usize, usize)>>;
            if y_start > 0 {
                y_start -= 1;
            } else {
                x_start += 1;
            }
            Some(ret)
        }))
    }

    fn diagonal_up(
        width: usize,
        height: usize,
    ) -> Box<dyn Iterator<Item = Box<dyn Iterator<Item = (usize, usize)>>>> {
        let mut x_start = 0;
        let mut y_start = WORD_SIZE - 1;
        Box::new(iter::from_fn(move || {
            if x_start + WORD_SIZE > width {
                return None;
            }
            let mut x = x_start;
            let mut y = y_start as isize;
            let ret = Box::new(iter::from_fn(move || {
                if x >= width || y < 0 {
                    return None;
                }
                let r = (x, y as usize);
                x += 1;
                y -= 1;
                Some(r)
            })) as Box<dyn Iterator<Item = (usize, usize)>>;
            if y_start < height - 1 {
                y_start += 1;
            } else {
                x_start += 1;
            }
            Some(ret)
        }))
    }

    #[cfg(test)]
    mod tests {
        use super::{diagonal_down, diagonal_up, find};

        #[test]
        fn test_diagonal_down() {
            let iter = diagonal_down(4, 5);
            let v: Vec<Vec<_>> = iter.map(|i| i.collect()).collect();
            assert_eq!(
                v,
                vec![
                    vec![(0, 1), (1, 2), (2, 3), (3, 4)],
                    vec![(0, 0), (1, 1), (2, 2), (3, 3)]
                ]
            )
        }

        #[test]
        fn test_diagonal_down2() {
            let iter = diagonal_down(5, 4);
            let v: Vec<Vec<_>> = iter.map(|i| i.collect()).collect();
            assert_eq!(
                v,
                vec![
                    vec![(0, 0), (1, 1), (2, 2), (3, 3)],
                    vec![(1, 0), (2, 1), (3, 2), (4, 3)]
                ]
            )
        }

        #[test]
        fn test_diagonal_up() {
            let iter = diagonal_up(4, 5);
            let v: Vec<Vec<_>> = iter.map(|i| i.collect()).collect();
            assert_eq!(
                v,
                vec![
                    vec![(0, 3), (1, 2), (2, 1), (3, 0)],
                    vec![(0, 4), (1, 3), (2, 2), (3, 1)]
                ]
            )
        }

        #[test]
        fn test_diagonal_up2() {
            let iter = diagonal_up(5, 4);
            let v: Vec<Vec<_>> = iter.map(|i| i.collect()).collect();
            assert_eq!(
                v,
                vec![
                    vec![(0, 3), (1, 2), (2, 1), (3, 0)],
                    vec![(1, 3), (2, 2), (3, 1), (4, 0)]
                ]
            )
        }

        #[test]
        fn test_find_diag_down() {
            let input = vec![
                vec!['.', '.', '.', '.', '.'],
                vec!['.', 'X', '.', '.', '.'],
                vec!['.', '.', 'M', '.', '.'],
                vec!['.', '.', '.', 'A', '.'],
                vec!['.', '.', '.', '.', 'S'],
            ];
            let sum = find(input);
            assert_eq!(sum, 1);
        }

        #[test]
        fn test_find_diag_down_rev() {
            let input = vec![
                vec!['.', '.', '.', '.', '.'],
                vec!['S', 'S', '.', '.', '.'],
                vec!['.', 'A', 'A', '.', '.'],
                vec!['.', '.', 'M', 'M', '.'],
                vec!['.', '.', '.', 'X', 'X'],
            ];
            let sum = find(input);
            assert_eq!(sum, 2);
        }

        #[test]
        fn test_find_none() {
            let input = vec![
                vec!['.', '.', 'A', 'S', '.'],
                vec!['.', 'M', '.', '.', '.'],
                vec!['X', '.', 'X', 'X', '.'],
                vec!['.', 'M', 'M', 'M', '.'],
                vec!['.', '.', 'A', 'A', '.'],
            ];
            let sum = find(input);
            assert_eq!(sum, 0);
        }

        #[test]
        fn test_find_diag_up() {
            let input = vec![
                vec!['.', '.', '.', '.', '.'],
                vec!['.', '.', '.', '.', 'S'],
                vec!['.', '.', '.', 'A', '.'],
                vec!['.', '.', 'M', '.', '.'],
                vec!['.', 'X', '.', '.', '.'],
            ];
            let sum = find(input);
            assert_eq!(sum, 1);
        }

        #[test]
        fn test_find_diag_up_rev() {
            let input = vec![
                vec!['.', '.', '.', 'X', '.'],
                vec!['.', '.', 'M', '.', '.'],
                vec!['.', 'A', '.', '.', '.'],
                vec!['S', '.', '.', '.', '.'],
                vec!['.', '.', '.', '.', '.'],
            ];
            let sum = find(input);
            assert_eq!(sum, 1);
        }

        #[test]
        fn test_find_vertical() {
            let input = vec![
                vec!['X', '.', 'S', '.', '.'],
                vec!['M', '.', '.', '.', 'S'],
                vec!['A', 'X', '.', '.', 'A'],
                vec!['S', 'M', '.', '.', 'M'],
                vec!['.', 'A', '.', '.', 'X'],
            ];
            let sum = find(input);
            assert_eq!(sum, 2);
        }

        #[test]
        fn test_find_horizontal() {
            let input = vec![
                vec!['X', 'M', 'A', 'S', '.'],
                vec!['.', '.', '.', '.', '.'],
                vec!['.', 'X', 'M', 'A', '.'],
                vec!['.', '.', '.', '.', '.'],
                vec!['.', 'S', 'A', 'M', 'X'],
            ];
            let sum = find(input);
            assert_eq!(sum, 2);
        }
    }
}

mod problem2 {
    const XMAS_WIDTH: usize = 3;
    const XMAS_HEIGHT: usize = 3;
    pub fn find(input: Vec<Vec<char>>) -> usize {
        let height = input.len();
        let width = input[0].len();
        (0..(width - XMAS_WIDTH + 1))
            .flat_map(|x| (0..(height - XMAS_HEIGHT + 1)).map(move |y| (x, y)))
            .filter(|(x, y)| {
                if input[*y + 1][*x + 1] != 'A' {
                    return false;
                }
                let x = [
                    input[*y][*x],
                    input[*y][*x + 2],
                    input[*y + 2][*x],
                    input[*y + 2][*x + 2],
                ];
                let mut m_count = 0;
                let mut s_count = 0;
                for c in x {
                    match c {
                        'M' => m_count += 1,
                        'S' => s_count += 1,
                        _ => (),
                    }
                }
                m_count == 2 && s_count == 2 && x[0] != x[3] && x[1] != x[2]
            })
            .count()
    }
    #[cfg(test)]
    mod test {
        use super::find;

        #[test]
        fn test_x_mas() {
            let input = vec![
                vec!['.', 'M', 'A', 'S', '.'],
                vec!['.', '.', 'A', '.', '.'],
                vec!['.', 'M', 'M', 'S', 'S'],
                vec!['.', '.', 'A', 'A', '.'],
                vec!['.', 'S', 'M', 'S', 'S'],
            ];
            let sum = find(input);
            assert_eq!(sum, 2);
        }
    }
}
