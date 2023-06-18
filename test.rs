#[macro_use(c)]
extern crate cute;
fn main(){
    let vector = c![x, for x in 1..10, if x % 2 == 0];
    println!("{}",vector.0);
}

