#include <stdio.h>
#include <stdint.h>
#include <math.h>

int main()
{
	int n = 256+64;
	int i;
	int8_t c;

	printf("sin_tbl:\n");
	for(i=0; i<n; i++)
	{
		if(i == 64)
		{
			printf("cos_tbl:\n");
		}
		if((i%8) == 0)
		{
			printf("    .db ");
		}
		c = round( sin(2.0 * M_PI * i / 256.0) * 64.0f );
		printf("$%02x%c", (uint8_t)c, ((i%8) == 7) ? '\n':',');
	}

	return 0;
}
