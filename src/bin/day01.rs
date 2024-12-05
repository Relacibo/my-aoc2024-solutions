use std::{
    fs::File,
    io::{BufRead, BufReader},
};

pub fn main() {
    let file = File::open("resources/day01/input.txt").unwrap();
    let (mut input_a, mut input_b): (Vec<_>, Vec<_>) = BufReader::new(file)
        .lines()
        .flatten()
        .flat_map(|line| {
            let v = line
                .split_whitespace()
                .take(2)
                .flat_map(|s| s.parse::<i64>().ok())
                .collect::<Vec<_>>();
            let &[a, b] = &v[..] else {
                return None;
            };
            Some((a, b))
        })
        .unzip();
    input_a.sort();
    input_b.sort();

    let distance = problem1::get_distance(&input_a, &input_b);
    println!("Problem 1 - distance: {distance}");
    let score = problem2::get_similarity_score(&input_a, &input_b);
    println!("Problem 2 - Similarity Score: {score}");
}

mod problem1 {
    pub fn get_distance(sorted_input_a: &[i64], sorted_input_b: &[i64]) -> i64 {
        sorted_input_a
            .into_iter()
            .zip(sorted_input_b)
            .map(|(a, b)| (a - b).abs())
            .sum()
    }
}

mod problem2 {
    pub fn get_similarity_score(sorted_input_a: &[i64], sorted_input_b: &[i64]) -> i64 {
        let mut iter_a = sorted_input_a.iter();
        let mut iter_b = sorted_input_b.iter().peekable();
        let mut pivot_next_a = iter_a.next();
        let mut sum = 0;
        while let Some(pivot_a) = pivot_next_a {
            let mut counter_a = 1;
            loop {
                let a = iter_a.next();
                if Some(pivot_a) != a {
                    pivot_next_a = a;
                    break;
                }
                counter_a += 1;
            }
            let mut counter_b = 0;
            while let Some(b) = iter_b.next_if(|b| *b <= pivot_a) {
                if b == pivot_a {
                    counter_b += 1;
                }
            }
            sum += pivot_a * counter_a * counter_b;
        }
        sum
    }

    #[cfg(test)]
    mod test {
        use super::get_similarity_score;

        #[test]
        fn test_similarity_none() {
            let a = vec![10];
            let b = vec![15];
            let score = get_similarity_score(&a, &b);
            assert_eq!(score, 0);
        }

        #[test]
        fn test_similarity() {
            let a = vec![15];
            let b = vec![15];
            let score = get_similarity_score(&a, &b);
            assert_eq!(score, 15);
        }

        #[test]
        fn test_similarity_double_a() {
            let a = vec![15, 15];
            let b = vec![15];
            let score = get_similarity_score(&a, &b);
            assert_eq!(score, 15 * 2);
        }

        #[test]
        fn test_similarity_double_b() {
            let a = vec![15];
            let b = vec![15, 15];
            let score = get_similarity_score(&a, &b);
            assert_eq!(score, 15 * 2);
        }

        #[test]
        fn test_similarity_double_both() {
            let a = vec![15, 15];
            let b = vec![15, 15];
            let score = get_similarity_score(&a, &b);
            assert_eq!(score, 15 * 2 * 2);
        }

        #[test]
        fn test_similarity_noise_a() {
            let a = vec![1, 2, 15, 16];
            let b = vec![15];
            let score = get_similarity_score(&a, &b);
            assert_eq!(score, 15);
        }

        #[test]
        fn test_similarity_noise_b() {
            let a = vec![15];
            let b = vec![1, 14, 15, 17];
            let score = get_similarity_score(&a, &b);
            assert_eq!(score, 15);
        }
    }
}
