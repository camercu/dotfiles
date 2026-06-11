fn pair(s: i32) -> (_, _) {
    let a = s + 1;
    let b = s + 2;

    return (a, b);
}

fn main() {
    let s = 1;

    let (a, b) = pair(s);

    println!("{}", a + b);
}
