//
//  Brot.metal
//  Metalbrot
//
//  Created by Joss Manger on 6/11/22.
//

#include "MetalHeaders.h"
#include <TargetConditionals.h>

#if TARGET_OS_TV
#define ITERATION_MAX 200
#else
#define ITERATION_MAX 100
#endif

#define MODULO_MAX 256

typedef enum {
    VertexIndex,
    ViewportSizeIndex,
    OriginIndex,
    ZoomRectIndex,
    BaseColorIndex
} MetalbrotBufferIndex;

#define ViewportSizeIndex 1
using namespace metal;


/**
 
 C sample code from CPU project:
 
 void drawEntireSet(FILE *fp, int width, int height, unsigned int r, unsigned int g, unsigned int b){
 
 (void) fprintf(fp, "P6\n%d %d\n255\n", width, height);
 
 int randomR = r;
 int randomB = b;
 int randomG = g;
 
 unsigned char other[3];
 
 for (int row = 0; row < height; row++) {
 for (int col = 0; col < width; col++) {
 double c_re = (col - width/2.0)*4.0/width;
 double c_im = (row - height/2.0)*4.0/width;
 double x = 0, y = 0;
 int iteration = 0;
 while (x*x+y*y <= 4 && iteration < ITERATION_MAX) {
 double x_new = x*x - y*y + c_re;
 y = 2*x*y + c_im;
 x = x_new;
 iteration++;
 }
 if (iteration < ITERATION_MAX) {
 int increase = iteration * 100;
 
 
 other[0] = randomR * increase;  // red
 other[1] = randomG * increase;   //green
 other[2] = randomB * increase;  //  blue
 
 (void) fwrite(other, 1, 3, fp);
 } else {
 (void) fwrite(black, 1, 3, fp);
 }
 }
 }
 
 }
 **/



/// Vertex function
vertex BrotVertexOut brot_vertex_main(BrotVertexIn vertex_in [[ stage_in ]],
                                      constant vector_uint2 *viewportSizePointer [[buffer(ViewportSizeIndex)]],
                                      constant vector_int2 *originPointer [[buffer(OriginIndex)]],
                                      constant vector_float2 *zoomPointer [[buffer(ZoomRectIndex)]],
                                      constant vector_float4 *color [[buffer(BaseColorIndex)]]
                                      ) {
    
    //define vertexOut struct
    BrotVertexOut out;
    
    //get xy position from vertex in
    out.position = float4(vertex_in.position,0.0,1.0);
    
    vector_uint2 viewportSize = *viewportSizePointer;
    
    //assign viewportSize to out struct
    out.viewportSize = viewportSize;
    out.origin = *originPointer;
    out.zoom = *zoomPointer;
    out.color = *color;
    
    //pass vertex on
    return out;
    
};

//http://en.wikipedia.org/wiki/HSL_color_space
//https://stackoverflow.com/questions/2353211/hsl-to-rgb-color-conversion
float hue2rgb(float3 pqtIn){ //(p ,q ,t)
    float p = pqtIn.x;
    float q = pqtIn.y;
    float t = pqtIn.z;
    
    if(t < 0)
        t += 1;
    if(t > 1)
        t -= 1;
    if(t < 1/6)
        return p + (q - p) * 6 * t;
    if(t < 1/2)
        return q;
    if(t < 2/3)
        return p + (q - p) * (2/3 - t) * 6;
    return p;
}

float4 hslToRGBA(float3 hslIn){
    
    float4 rgbaOut = {0,0,0,1};
    float h = hslIn.x;
    float s = hslIn.y;
    float l = hslIn.z;
    float q,p = 0;
    
    if (s == 0) {
        rgbaOut.rgb = l; // achromatic
    } else {
        q = l < 0.5 ? l * (1 + s) : l + s - l * s;
        p = 2 * l - q;
        rgbaOut.r = hue2rgb({p, q, h + 1/3});
        rgbaOut.g = hue2rgb({p, q, h});
        rgbaOut.b = hue2rgb({p, q, h - 1/3});
    }
    
    return rgbaOut;
    
}


/// Fragment Function - assigns colors to individually rasterized pixels in the form of the Mandelbrot set
fragment FragmentOut brot_fragment_main(BrotVertexOut in [[stage_in]]) {
    
    FragmentOut fragOut;
    float4 black = float4(0,0,0,1);
    float4 out = black;

    const float pixX = in.position.x ;// + 500;
    const float pixY = in.position.y ;// + 800;
    const float width = in.viewportSize.x;
    const float height = in.viewportSize.y;
    
    const float pxXScaleFactor = in.viewportSize.x / in.zoom.x; // a low number
    const float pxYScaleFactor = in.viewportSize.y / in.zoom.y;

    const float dimensionXMax = in.origin.x * pxXScaleFactor;
    const float dimensionYMax = in.origin.y * pxYScaleFactor;
    
    const float adjustedPixX = ((pixX / width) * (in.zoom.x * pxXScaleFactor)) + dimensionXMax;
    const float adjustedPixY = ((pixY / height) * (in.zoom.y * pxYScaleFactor)) + dimensionYMax;// + magicVAdjust;

    const float adjustedWidth = width * pxXScaleFactor;
    const float adjustedHeight = height * pxYScaleFactor;
    
    const float c_re = (adjustedPixX - adjustedWidth/2.0)*4.0/adjustedWidth;
    const float c_im = (adjustedPixY - adjustedHeight/2.0)*4.0/adjustedWidth; //height/width constrains proportions
    float x = 0, y = 0;
    
    uint iteration = 0;

    while (x*x+y*y <= 4 && iteration < ITERATION_MAX) {
        half x_new = x*x - y*y + c_re;
        y = 2*x*y + c_im;
        x = x_new;
        iteration++;
    }
    
    if (iteration < ITERATION_MAX) {
        
        float iterationFactor = float(iteration) / ITERATION_MAX;
        out = hslToRGBA({iterationFactor,1.0,0.8});

    } else {
        //write black to "void:"
        out = black;
    }
    
    fragOut.color = out;
    
    return fragOut;
    
}

