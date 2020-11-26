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
 * Convert rgb888 colors to rgb333.
 * author : MooZ
 */
#include "vce.h"

void color_convert(uint8_t *in, uint8_t *out, int color_count)
{
    int i;
    for(i=0; i<color_count; i++, in+=3)
    {
        *out++ = ((in[1] << 1) & 0xc0) | ((in[0] >> 2) & 0x38) | (in[2] >> 5);
        *out++ = ((in[1] >> 7) & 0x01);
    }
}
