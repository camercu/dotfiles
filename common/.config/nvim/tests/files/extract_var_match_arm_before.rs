fn main() {
    let x = 2;
    let y = match x {
        _ => (1 + 2) * 3,
    };
    let _ = y;
}
