#include "print.h"

void print_table(const char* name, const int8_t* table, int count)
{
    int i;
    printf("%s:\n", name);
    for(i=0; i<count; i++)
    {
        if((i%16) == 0)
        {
            printf("    .db ");
        }
        printf("$%02x%c", (uint8_t)table[i], (((i%16) == 15) || (i >= (count-1))) ? '\n':',');
    }
}
