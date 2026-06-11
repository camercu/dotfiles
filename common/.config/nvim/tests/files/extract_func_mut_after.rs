fn step(acc: i32) -> i32 {
    acc += 1;
    acc *= 2;

    return acc;
}

fn main() {
    let mut acc = 0;

    let acc = step(acc);

    println!("{}", acc);
}
