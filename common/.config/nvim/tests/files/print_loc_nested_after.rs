fn main() {
    let foo = 1;
    if foo > 0 {
        let bar = foo + 1;
        // __PRINT_LOC_START
        println!("┆main#if┆ ┊1┊");// __PRINT_LOC_END
        let _ = bar;
    }
}
