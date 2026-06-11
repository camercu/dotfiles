fn main() {
    let foo = 1 + 2;
    let f = |x: i32| x * (foo);
    let _ = f(1);
}
