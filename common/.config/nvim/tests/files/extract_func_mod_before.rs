fn helper() -> i32 {
    42
}

#[cfg(test)]
mod tests {
    fn check() {
        let a = 1;
        let b = 2;

        let c = a + b;
        assert_eq!(c, 3);

        let _ = a;
    }
}
