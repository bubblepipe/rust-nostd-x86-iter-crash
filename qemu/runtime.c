// Minimal C runtime for bare metal

void *memset(void *s, int c, unsigned long n) {
    unsigned char *p = s;
    while (n--) {
        *p++ = (unsigned char)c;
    }
    return s;
}

void *memcpy(void *dest, const void *src, unsigned long n) {
    unsigned char *d = dest;
    const unsigned char *s = src;
    while (n--) {
        *d++ = *s++;
    }
    return dest;
}

int bcmp(const void *s1, const void *s2, unsigned long n) {
    const unsigned char *p1 = s1;
    const unsigned char *p2 = s2;
    while (n--) {
        if (*p1++ != *p2++) {
            return 1;
        }
    }
    return 0;
}

// Dummy personality function for unwinding (we panic=abort so this shouldn't be called)
void rust_eh_personality() {}