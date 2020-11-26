#include <errno.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#include "utils/raw.h"

#define swap(a,b) do { uint8_t c = a; a = b; b = c; } while(0);

uint8_t reverse(uint8_t b) {
   b = (b & 0xF0) >> 4 | (b & 0x0F) << 4;
   b = (b & 0xCC) >> 2 | (b & 0x33) << 2;
   b = (b & 0xAA) >> 1 | (b & 0x55) << 1;
   return b;
}

void output(uint8_t *t0, uint8_t *t1) {
    /*
    for(int j=0; j<32; j++) {
        printf("%02d: ", j);
        for(int i=0; i<8; i++) {
            printf("%c", ((b0[j] >> i) & 1) ? 'X' : '.');
        }
        printf("    ");
        for(int i=0; i<8; i++) {
            printf("%c", ((b1[j] >> i) & 1) ? 'X' : '.');
        }
        printf("\n");
    }
    printf("\n\n");
    */
    for(size_t j=0; j<16; j+=2) {
        uint8_t b0, b1, b2, b3;
        b0 = t0[j+0];
        b1 = t0[j+1];
        b2 = t0[j+16];
        b3 = t0[j+17];
        for(size_t i=0; i<8; i++) {
            uint8_t b = (((b0 >> i) & 1)     )
                      | (((b1 >> i) & 1) << 1)
                      | (((b2 >> i) & 1) << 2)
                      | (((b3 >> i) & 1) << 3);
            printf("%2d ", b);
        }
        printf("    ");
        b0 = t1[j+0];
        b1 = t1[j+1];
        b2 = t1[j+16];
        b3 = t1[j+17];
        for(size_t i=0; i<8; i++) {
            uint8_t b = (((b0 >> i) & 1)     )
                      | (((b1 >> i) & 1) << 1)
                      | (((b2 >> i) & 1) << 2)
                      | (((b3 >> i) & 1) << 3);
            printf("%2d ", b);
        }
        printf("\n");
    }
    printf("\n");
}

int main(int argc, char* const argv[])
{
    int ret = 1;
    size_t len;
    uint8_t *buffer;
        
    FILE *in = fopen(argv[1], "rb");
    fseek(in, 0, SEEK_END);
    len = ftell(in);
    fseek(in, 0, SEEK_SET);
    len -= ftell(in);
    buffer = (uint8_t*)malloc(len);
    fread(buffer, 1, len, in);
    fclose(in);

    size_t count = len/32;
    
    size_t match = 0;
    for(size_t i=0; i<count/2; i++) {
        size_t t = i*32;
        uint8_t tmp[32];
        
        memcpy(tmp, &buffer[t], 32);
        
        for(size_t j=0; j<32; j++) {
            tmp[j] = reverse(tmp[j]);
        }
        for(size_t j=0; j<8; j+=2) {
            swap(tmp[j+ 0], tmp[14-j]); 
            swap(tmp[j+ 1], tmp[15-j]);
            swap(tmp[j+16], tmp[30-j]); 
            swap(tmp[j+17], tmp[31-j]);
        }
        
        for(size_t j=0; j<16; j+=2) {
            tmp[j+ 0] ^= 0xff;
            tmp[j+ 1] ^= 0xff;
            tmp[j+16] ^= 0xff;
            tmp[j+17] ^= 0xff;

        /*
            uint8_t b0 = tmp[j+0];
            uint8_t b1 = tmp[j+1];
            uint8_t b2 = tmp[j+16];
            uint8_t b3 = tmp[j+17];            
            tmp[j+0] = 0;
            tmp[j+1] = 0;
            tmp[j+16] = 0;
            tmp[j+17] = 0;
            for(size_t i=0; i<8; i++) {
                uint8_t b = (((b0 >> i) & 1)     )
                          | (((b1 >> i) & 1) << 1)
                          | (((b2 >> i) & 1) << 2)
                          | (((b3 >> i) & 1) << 3);
                b = 15 - b;
                tmp[j+0]  |= ((b & 1)   ) << i;
                tmp[j+1]  |= ((b & 2)>>1) << i;
                tmp[j+16] |= ((b & 4)>>2) << i;
                tmp[j+17] |= ((b & 8)>>3) << i;
            }*/
        }
        for(size_t j=count/2; j<count; j++) {
            if(memcmp(tmp, &buffer[j*32], 32) == 0) {
                match++;
                break;
            }
        }
    }
    printf("%ld %ld\n", match, count/2);
    
    free(buffer);
    return ret ?     EXIT_SUCCESS : EXIT_FAILURE;
}
