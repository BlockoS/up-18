#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdint.h>

#include "utils/print.h"

uint8_t reverse(uint8_t b) {
   b = (b & 0xF0) >> 4 | (b & 0x0F) << 4;
   b = (b & 0xCC) >> 2 | (b & 0x33) << 2;
   b = (b & 0xAA) >> 1 | (b & 0x55) << 1;
   return b;
}

int main() {
    int8_t tab[256];
    unsigned int i;
    for(i=0; i<256; i++) {
        tab[i] = (int8_t)(reverse(i) ^ 0xff);
    }
    print_table("reverse_xor", tab, 256);
    return EXIT_SUCCESS;
}