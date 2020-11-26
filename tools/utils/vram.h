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
 * Convert image to vram formats (tile and sprite).
 * author : MooZ
 */
#ifndef VRAM_H
#define VRAM_H

#include <stddef.h>

#include "image.h"

int bitmap_to_tile(uint8_t *out, uint8_t *in, int stride);
int bitmap_to_sprite(uint8_t *out, uint8_t *in, int stride);

int image_to_tiles(Image *img, int bloc_width, int bloc_height, uint8_t *buffer, size_t *size);
int image_to_sprites(Image *img, int sprite_width, int sprite_height, uint8_t *buffer, size_t *size);

#endif /* VRAM_H */
