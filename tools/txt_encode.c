#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <stdint.h>

typedef const char* const_str;
typedef const_str entry_t[4];

#define CURVE_POINTS 128

const entry_t greetings[] =
{
    {
        "INVITES YOU TO",
        NULL,
        NULL,
        NULL
    },
    {
        "THIS SUMMER",
        "COME ENJOY",
        "THE DATAYARD",
        "SOMMARBRISEN"
    },
    {
        "AT THE WORLD'S",
        "FINEST",
        "OLDSKOOL",
        "DEMOPARTY"
    },
    {
        "3-5 AUGUST",
        "GOTHENBURG",
        "KINGDOM OF",
        "SWEDEN"
    },
    {
        "SAME OLE PLACE",
        NULL,
        NULL,
        NULL
    },
    {
        "YE OLE",
        "TRUCKSTOP",
        "ALASKA",
        NULL
    },
    {
        "FINE BREWS",
        "AND EXQUISITE",
        "CUISINE",
        "AWAIT YOU"
    },
    {
        "COME HEAR TALES",
        "FROM THE",
        "DARK AGES",
        "OF THE SCENE"
    },
    {
        "AND TAKE PART",
        "IN ONE OF THE",
        "MOST EXCITING",
        "TOURNAMENTS"
    },
    {
        "SO FASTEN YOUR",
        "UNDERPANTS",
        "AND SCRUB YOUR",
        "BRAIN CELLS"
    },
    {
        "BEHOLD",
        "THE DATASTORM",
        "COMETH",
        NULL
    },
    {
        "*CREDITS*",
        NULL,
        NULL,
        NULL
    },
    {
        "CODE: MOOZ",
        "GFX: EXOCET",
        "MUSIC: OCTAPUS",
        NULL
    },
    {
        "AS THEY SAY",
        "IN THE U.S",
        "BE THERE OR BE",
        "="
    }
};

const size_t charLen[] =
{
    //   ! " # $ % & ' ( ) * + , - . / 0 1 2 3
    16, 9, 9, 16, 16, 10, 16, 8, 9, 9, 12, 11, 7, 10, 8, 10, 10, 8, 10, 10,
    // 4 5 6 7 8 9 : ; < = > ? @ A B C D E F G
    10, 10, 10, 10, 10, 10, 9, 16, 16, 16, 16, 10, 9, 10, 10, 10, 10, 10, 9, 10,
    // H I J K L M N O P Q R S T U V W X Y Z [
    10, 9, 10, 9, 7, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 16
};

const size_t maxLen = 16;
const size_t spriteWidth  = 16;
const size_t spriteHeight = 16;
const size_t spriteHSpacing = 16;
const size_t spriteVSpacing = 16+6;
const size_t screenWidth  = 256;
const size_t screenHeight = 240;
const size_t yoff = 64;
const size_t xoff = 32;

void PrintArray(FILE* out, const char name[], int16_t tab[CURVE_POINTS])
{
    int i;
    char c;
    fprintf(out, "%s:\n", name);
    for(i=0; i<CURVE_POINTS; i++)
    {
        if((i%8) == 0)
        {
            fprintf(out, "\t.dw ");
        }
        c = ((i+1)%8) ? ',' : '\n';
        
        fprintf(out, "%4d%c", tab[i], c);
    }
}

void GenerateCurve()
{
    FILE *txtOut;
    int i;
    int pmax = CURVE_POINTS/2-1;
    int16_t x[CURVE_POINTS], y[CURVE_POINTS];
    
    for(i=0; i<CURVE_POINTS; i++)
    {
        double s = (pmax - i) / (double)pmax;
        double t = 4.0 * M_PI * s;
        double sn = sin(t);
        double cs = cos(t);
        double a =  s * sn * 128.0;
        double b = -s * cs * 160.0;
        x[i] = (int16_t)rint(a);
        y[i] = (int16_t)rint(b);
    }

    txtOut = fopen("curve.dat", "wb");
    for(i=0; i<CURVE_POINTS; i++)
    {
        fprintf(txtOut, "%d    %d\n", x[i], y[i]);
    }
    fclose(txtOut);

    txtOut = fopen("curve.inc", "wb");
    fprintf(txtOut, "SPIRAL_POINT_COUNT = %d\n", CURVE_POINTS); 
    PrintArray(txtOut, "spiral_x", x);
    PrintArray(txtOut, "spiral_y", y);
    fclose(txtOut);
}

int main()
{
    size_t elementCount = sizeof(greetings) / sizeof(greetings[0]);
    int i, j, k;
    size_t x, y;
    size_t len;
    size_t ymax;
    size_t w;
    unsigned char buffer[256];
    
    FILE *txtOut;
    
    txtOut = fopen("invtro_txt.inc", "wb");
    fprintf(txtOut, "TXT_COUNT = %d\n"
                    "TXT_V_SPACING = %d\n"
                    "TXT_H_SPACING = %d\n"
                    "TXT_SPACING = %d\n"
                    "txtData:\n", elementCount, spriteVSpacing, spriteHSpacing*2, spriteHSpacing);
                
    ymax = 0;
    for(i=0; i<elementCount; i++)
    {
        for(j=0; j<4; j++)
        {
            if(greetings[i][j] == NULL)
            {
                break;
            }
        }
        
        y = (screenHeight - j*spriteVSpacing) /2;
        if(y > ymax) { ymax = y; }

        fprintf(txtOut, "\t.db ");
        fprintf(txtOut, "%3d, %3d\n", j, y+yoff);
 
        for(j=0; j<4; j++)
        {
            if(greetings[i][j] == NULL)
            {
                break;
            }
            
            len = strlen(greetings[i][j]);
            
            fprintf(txtOut, "\t.db ");
            w = 0;
            for(k=0; k<len; k++)
            {
                unsigned char c = greetings[i][j][k];
                if((c < ' ') || (c > '[')) {
                    c = ' ';
                }
                c -= ' ';
                buffer[k] = c;
                w += charLen[c];
            }
            
            x = (screenWidth - w)/2;
            fprintf(txtOut, "%3d, ", x+xoff);
            
            for(k=0; k<len; k++)
            {
                fprintf(txtOut, "$%02x,", buffer[k]);
            }
            fprintf(txtOut, "$ff\n");
        }        
    }

    fclose(txtOut);
    
    //GenerateCurve();
    
    return 0;
}
