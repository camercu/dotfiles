fn add(a: i32, b: i32) -> i32 {
    let c: i32 = a + b;
    println!("{}", c);

    return c;
}

fn main() {
    let a = 1;
    let b: i32 = 2;

    let c = add(a, b);

    let d = c * 2;
    println!("{}", d);
}
