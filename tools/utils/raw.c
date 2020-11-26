/* 
 *           DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
 *                    Version 2, December 2004
 *  
 * Copyright (C) 2004 Sam Hocevar <sam@hocevar.net>
 * 
 * Everyone is permitted to copy and distribute verbatim or modified
 * copies of this license document, and changing it is allowed as long
 * as the name is changed.
 *  
 *            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
 *   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
 *  
 *  0. You just DO WHAT THE FUCK YOU WANT TO.
 */
/* 
 * Write raw bytes to file.
 * author : MooZ
 */
#include "raw.h"

#include <stdio.h>
#include <string.h>
#include <errno.h>

int write_raw(const char* filename, uint8_t* buffer, size_t sz)
{
    FILE *out;
    size_t nwritten;
    int ret = 1;
    
    out = fopen(filename, "wb");
    if(NULL == out)
    {
        fprintf(stderr, "Failed to open %s: %s\n", filename, strerror(errno));
        return 0;
    }
    
    nwritten = fwrite(buffer, 1, sz, out);
    if(sz != nwritten)
    {
        ret = 0;
        fprintf(stderr, "failed to write %zu bytes to %s: %s\n", sz, filename, strerror(errno));
    }
    fclose(out);
    return ret;
}
