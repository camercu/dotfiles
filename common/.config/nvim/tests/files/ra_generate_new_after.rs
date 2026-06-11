struct Point {
    x: i32,
    y: i32,
}

impl Point {
    fn new(x: i32, y: i32) -> Self {
        Self { x, y }
    }
}

fn main() {
    let p = Point { x: 1, y: 2 };
    let _ = (p.x, p.y);
}
