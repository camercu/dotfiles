fn sum(a: _, b: _) {
    let c = a + b;
    println!("{}", c);
}

fn main() {
    let (a, b) = (1, 2);

    sum(a, b);

    let d = 3;
    let _ = d;
}
