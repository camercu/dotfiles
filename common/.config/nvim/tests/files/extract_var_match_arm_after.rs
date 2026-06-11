fn main() {
    let x = 2;
    let foo = 1 + 2;
    let y = match x {
        _ => (foo) * 3,
    };
    let _ = y;
}
