#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <uk/plat/memory.h>
#include "bmp.h"

volatile int c = 4;
volatile int d;

extern char *gop_fb;
extern __u32 gop_xmax, gop_ymax, gop_ppsl;

static void plot_pixel(int x, int y, __u32 p)
{
    *((__u32*)(gop_fb + 4 * gop_ppsl * y + 4 * x)) = p;
}

int main(int argc, char *argv[])
{
    struct ukplat_memregion_desc *initrd;
    __u32 i, j, k, p;
    __u32 *bitmap;
    bmp b;

    if (ukplat_memregion_find_initrd0(&initrd) < 0)
        goto busy_loop;


    b.bf = (bmp_fhdr *)initrd->vbase;
    b.bi = (bmp_ihdr *)(initrd->vbase + sizeof(*b.bf));
    b.pad = b.bi->width % 4;
    bitmap = (__u32 *)(initrd->vbase + b.bf->imageDataOffset);

    b.bi->height *= -1;
    for (j = 0; j < b.bi->width; j++)
        for (i = 0; i < b.bi->height; i++) {
            plot_pixel(j, i, bitmap[i * b.bi->width + j]);
        }
busy_loop:
    while (1);

    return 0;
}
