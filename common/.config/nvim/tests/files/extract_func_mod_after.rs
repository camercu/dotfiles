fn helper() -> i32 {
    42
}

#[cfg(test)]
mod tests {
    fn add(a: i32, b: i32) {
    let c = a + b;
    assert_eq!(c, 3);
}

fn check() {
        let a = 1;
        let b = 2;

        add(a, b);

        let _ = a;
    }
}
