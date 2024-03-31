#pragma pack(1)

typedef struct
{
    unsigned char  fileMarker1; /* 'B' */
    unsigned char  fileMarker2; /* 'M' */
    unsigned int   bfSize; /* File's size */
    unsigned short unused1; /* Aplication specific */
    unsigned short unused2; /* Aplication specific */
    unsigned int   imageDataOffset; /* Offset to the start of image data */
} bmp_fhdr;

typedef struct
{
    unsigned int   biSize; /* Size of the info header - 40 bytes */
    signed int     width; /* Width of the image */
    signed int     height; /* Height of the image */
    unsigned short planes;
    unsigned short bitPix; /* Number of bits per pixel = 3 * 8 (for each channel R, G, B we need 8 bits */
    unsigned int   biCompression; /* Type of compression */
    unsigned int   biSizeImage; /* Size of the image data */
    int            biXPelsPerMeter;
    int            biYPelsPerMeter;
    unsigned int   biClrUsed;
    unsigned int   biClrImportant;
} bmp_ihdr;

// struct to store a pixel's coordinates in a bitmap
typedef struct {
    int x, y;
} pair;

typedef struct {
    char p[3];
} pixel;

//struct to store the image's metadata
typedef struct {
    signed int pad;
    bmp_fhdr *bf;  // bmp_fileheader
    bmp_ihdr *bi;  // bmp_infoheader
    pixel *bitmap;
} bmp;

#pragma pack()
