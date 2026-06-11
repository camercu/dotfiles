struct Counter {
    count: i32,
}

impl Counter {
    fn bump(&mut self) {
        self.count += 1;

        let doubled = self.count * 2;
        println!("{}", doubled);

        self.count = 0;
    }
}
