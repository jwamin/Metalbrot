//
//  Brot.metal
//  Metalbrot
//
//  Created by Joss Manger on 6/11/22.
//

#include "MetalHeaders.h"

#define ITERATION_MAX 100
#define MODULO_MAX 256
#define AAPLVertexInputIndexViewportSize 1
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
                                      constant vector_uint2 *viewportSizePointer [[buffer(AAPLVertexInputIndexViewportSize)]],
                                      constant vector_int2 *originPointer [[buffer(2)]],
                                      constant vector_int2 *zoomPointer [[buffer(3)]]
                                      ) {
    
    //define vertexOut struct
    BrotVertexOut out;
    
    //get xy position from vertex in
    out.position = float4(vertex_in.position,0.0,1.0);
    
    vector_float2 viewportSize = vector_float2(*viewportSizePointer);
    
    //assign viewportSize to out struct
    out.viewportSize = viewportSize;
    out.origin = vector_float2(*originPointer);
    out.zoom = vector_float2(*zoomPointer);
    //pass vertex on
    return out;
    
};


/// Fragment Function - assigns colors to individually rasterized pixels in the form of the Mandelbrot set
fragment float4 brot_fragment_main(BrotVertexOut in [[stage_in]]) {
    
    //pass on color to fragment
    float4 black = float4(0,0,0,1);
    //float4 error = float4(1.0,0.0,1.0,1);
    float4 out = float4(0.0,0.0,0.0,1);
    
    /// \param maxX the the width of the full mandelbrot set image
    /// \param maxY the height of the full mandelbrot set image
    /// \param originX the origin horizontal pixel of the sub rect of mandelbrot set we are rendering
    /// \param originY the origin vertical pixel of the sub rect of mandelbrot set we are rendering
    /// \param dimensionX the width of the drawing region of mandelbrot set
    /// \param dimensionY the height of the drawing region of mandelbrot set
//    int dimensionXMax = originX + dimensionX;
//    int dimensionYMax = originY + dimensionY;
//
//    for (int row = originY; row < dimensionYMax; row++) {
//        for (int col = originX; col < dimensionXMax; col++) {
    
// INSIDE SHADER CODE
//            double c_re = (col - maxX / 2.0) * 4.0 / maxX;
//            double c_im = (row - maxY / 2.0) * 4.0 / maxX;
    

    half col = in.position.x ;// + 500;
    half row = in.position.y ;// + 800;
    
    half width = in.viewportSize.x;
    half height = in.viewportSize.y;
    
    half dimensionXMax = in.origin.x + in.zoom.x;
    half dimensionYMax = in.origin.y + in.zoom.y;

    half centerX = width / 2;
    half centerY = height / 2;
    
    
    half adjustedColX = ((col / width) * dimensionXMax) + in.origin.x;
    half adjustedColY = ((row / height) * dimensionYMax) + in.origin.y + (height / 4);

    half adjustedWidth = width;
    half adjustedHeight = height;
    
    half randomR = 1.0;
    half randomG = 1.0;
    half randomB = 1.0;
    
    half c_re = (adjustedColX - adjustedWidth/2.0)*4.0/adjustedWidth;
    half c_im = (adjustedColY - adjustedHeight/2.0)*4.0/adjustedWidth; //height/width constrains proportions
    half x = 0, y = 0;
    int iteration = 0;
    while (x*x+y*y <= 4 && iteration < ITERATION_MAX) {
        half x_new = x*x - y*y + c_re;
        y = 2*x*y + c_im;
        x = x_new;
        iteration++;
    }
    
    if (iteration < ITERATION_MAX) {
        
        half halfiteration = iteration;
        half normalizedIncrease = halfiteration / 100;
        
        out.z = randomR * (normalizedIncrease / 0.333);   /* red */
        
        if (normalizedIncrease > 0.333){
            out.y = randomG * (normalizedIncrease / 0.666); //* normalizedIncrease;   /* green */
        }
        if (normalizedIncrease > 0.666){
            out.x = randomB * (normalizedIncrease / 1.0); //* normalizedIncrease;  /* blue */
        }
        return out;
    }
    //write black to "void:"
    return black;
    
}

