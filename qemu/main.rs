#![no_std]
#![no_main]

use core::panic::PanicInfo;

// Serial port base address
const SERIAL_PORT: u16 = 0x3F8;

// Simple serial output
unsafe fn outb(port: u16, val: u8) {
    core::arch::asm!("out dx, al", in("dx") port, in("al") val);
}

fn serial_write_byte(b: u8) {
    unsafe {
        outb(SERIAL_PORT, b);
    }
}

fn serial_write(s: &str) {
    for b in s.bytes() {
        serial_write_byte(b);
    }
}

#[panic_handler]
fn panic(_: &PanicInfo) -> ! {
    serial_write("PANIC!\n");
    loop {}
}

#[no_mangle]
pub extern "C" fn rust_main() -> ! {
    // Initialize serial port (minimal setup)
    unsafe {
        outb(SERIAL_PORT + 1, 0x00);    // Disable interrupts
        outb(SERIAL_PORT + 3, 0x80);    // Enable DLAB
        outb(SERIAL_PORT + 0, 0x03);    // Set divisor (38400 baud)
        outb(SERIAL_PORT + 1, 0x00);
        outb(SERIAL_PORT + 3, 0x03);    // 8 bits, no parity, one stop bit
        outb(SERIAL_PORT + 2, 0xC7);    // Enable FIFO
    }
    
    serial_write("Starting iterator bug test...\n");
    
    // Test 1: windows().enumerate() - should work
    {
        serial_write("Test 1: windows().enumerate()...");
        let data: [bool; 4] = [false, true, false, false];
        let mut iter = data.windows(1).enumerate();
        let _ = iter.next();
        serial_write(" PASSED\n");
    }
    
    // Test 2: windows().enumerate().filter_map() - crashes on x86
    {
        serial_write("Test 2: windows().enumerate().filter_map()...");
        let data: [bool; 4] = [false, true, false, false];
        let mut iter = data
            .windows(1)
            .enumerate()
            .filter_map(|(i, _)| Some(i));
        
        // THIS WILL CRASH ON X86
        let _ = iter.next();
        
        serial_write(" PASSED\n");
    }
    
    serial_write("All tests completed!\n");
    
    loop {}
}