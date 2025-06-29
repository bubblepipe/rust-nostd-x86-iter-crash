// Test program to see what the iterator should return in a normal environment

fn main() {
    println!("Testing windows().enumerate().filter_map() in std environment:");
    
    let data: [bool; 4] = [false, true, false, false];
    
    // First, let's see what windows(1) produces
    println!("\nwindows(1) output:");
    for (i, window) in data.windows(1).enumerate() {
        println!("  Index {}: {:?}", i, window);
    }
    
    // Now the full chain
    println!("\nwindows(1).enumerate().filter_map(|(i, _)| Some(i)):");
    let mut iter = data
        .windows(1)
        .enumerate()
        .filter_map(|(i, _)| Some(i));
    
    // Get all results
    let results: Vec<usize> = iter.collect();
    println!("  Results: {:?}", results);
    
    // Or step by step
    println!("\nStep by step with next():");
    let mut iter2 = data
        .windows(1)
        .enumerate()
        .filter_map(|(i, _)| Some(i));
    
    println!("  iter.next() = {:?}", iter2.next());
    println!("  iter.next() = {:?}", iter2.next());
    println!("  iter.next() = {:?}", iter2.next());
    println!("  iter.next() = {:?}", iter2.next());
    println!("  iter.next() = {:?}", iter2.next());
    
    // Test with actual filtering
    println!("\nWith actual filtering - only indices where window[0] is false:");
    let mut iter3 = data
        .windows(1)
        .enumerate()
        .filter_map(|(i, w)| if !w[0] { Some(i) } else { None });
    
    let filtered: Vec<usize> = iter3.collect();
    println!("  Filtered results: {:?}", filtered);
}