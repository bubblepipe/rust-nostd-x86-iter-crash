#![no_std]
#![no_main]

use core::panic::PanicInfo;

#[panic_handler]
fn panic(_: &PanicInfo) -> ! {
    loop {}
}

#[no_mangle]
pub extern "C" fn _start() -> ! {
    let data: [bool; 4] = [false, true, false, false];
    
    // This crashes on x86_64 no_std:
    let mut iter = data
        .windows(1)
        .enumerate()
        .filter_map(|(i, _)| Some(i));
    
    let _ = iter.next(); // CRASH HERE
    
    loop {}
}