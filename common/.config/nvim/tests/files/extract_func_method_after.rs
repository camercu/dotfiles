struct Counter {
    count: i32,
}

impl Counter {
    fn show(&self) {
        let doubled = self.count * 2;
        println!("{}", doubled);
    }

    fn bump(&mut self) {
        self.count += 1;

        self.show();

        self.count = 0;
    }
}
