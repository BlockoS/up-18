#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main()
{
    int i, j;
    unsigned int dict[256];
    memset(dict, 0, 256*sizeof(unsigned int));

    j = 0;
    for(i='A'; i<='Z'; i++)
    {
        dict[i] = j++;
    }
    for(i='0'; i<='9'; i++)
    {
        dict[i] = j++;
    }
    dict['!'] = j++;
    dict['?'] = j++;
    dict['.'] = j++;
    dict[','] = j++;
    dict[' '] = 0xfe;
    dict['\n'] = 0xff;

    j = 8;
    while((i = getchar()) != EOF)
    {
        if(j >= 8)
        {
            printf("\n\t.db $%02x", dict[i]);
            j = 0;
        }
        else
        {
            printf(",$%02x", dict[i]);
            j++;
        }
    }
    printf("\n");
    return EXIT_SUCCESS;
}
