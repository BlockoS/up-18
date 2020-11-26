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
 * Simple png reader.
 * author : MooZ
 */
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <errno.h>
#include <png.h>
#include <zlib.h>

#include "image.h"

/**
 * Load a png image file.
 **/
int png_load(const char* filename, Image* dest)
{
    int ret;
    png_image image;
    
    dest->data    = NULL;
    dest->palette = NULL;
    
    memset(&image, 0, sizeof(png_image));    
    image.version = PNG_IMAGE_VERSION;
    
    ret = png_image_begin_read_from_file(&image, filename);
    if(0 == ret)
    {
        fprintf(stderr, "Read error: %s\n", image.message);        
    }

// [todo] check for colormap

    if(ret)
    {
        dest->width  = image.width;
        dest->height = image.height;
        dest->bytes_per_pixel = PNG_IMAGE_PIXEL_COMPONENT_SIZE(image.format);
        dest->data = malloc(PNG_IMAGE_SIZE(image));
        if(NULL == dest->data)
        {
            fprintf(stderr, "Unable to allocate buffer: %s\n", strerror(errno));
            ret = 0;
        }
    }
    
    if(ret)
    {
        dest->color_count = image.colormap_entries;
        dest->palette = malloc(PNG_IMAGE_COLORMAP_SIZE(image));
        if(NULL == dest->palette)
        {
            fprintf(stderr, "Unable to allocate buffer: %s\n", strerror(errno));
            ret = 0;
        }
    }

    if(ret)
    {
        ret = png_image_finish_read(&image, NULL, dest->data, 0, dest->palette);
        if(0 == ret)
        {
            fprintf(stderr, "Read error: %s\n", image.message);
        }
    }
    
    if(0 == ret)
    {
        destroy_image(dest);
    }
    return ret;
}
