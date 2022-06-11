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


                 other[0] = randomR * increase;  /* red */ /*
                 other[1] = randomG * increase ;   /* green */ /*
                 other[2] = randomB * increase;  /* blue */
/*
                 (void) fwrite(other, 1, 3, fp);
             } else {
                 (void) fwrite(black, 1, 3, fp);
             }
         }
     }

 }
 **/



vertex BrotVertexOut brot_vertex_main(BrotVertexIn vertex_in [[ stage_in ]],
                                      constant vector_uint2 *viewportSizePointer [[buffer(AAPLVertexInputIndexViewportSize)]]) {
  
  //define vertexOut struct
  BrotVertexOut out;
  
  //get xy position from vertex in
  out.position = float4(vertex_in.position,0.0,1.0);
  vector_float2 viewportSize = vector_float2(*viewportSizePointer);
  //out.heightWidth = vertex_in.heightWidth;
  //assign color to vertex out but vertex index
  //out.color = vertex_in.color;
    out.viewportSize = viewportSize;
  //pass vertex on
  return out;
  
};

fragment float4 brot_fragment_main(BrotVertexOut in [[stage_in]]) {

  //pass on color to fragment
    float4 black = float4(0,0,0,1);
    //float4 error = float4(1.0,0.0,1.0,1);
    float4 out = float4(0.0,0.0,0.0,1);
  
    half col = in.position.x;
    half row = in.position.y;
    half width = in.viewportSize.x;//1284.0;//in.heightWidth.x;
    half height = in.viewportSize.y;//2535.0;//in.heightWidth.y;
    
    half randomR = 1.0;
    half randomG = 1.0;
    half randomB = 1.0;
    
    half c_re = (col - width/2.0)*4.0/width;
    half c_im = (row - height/2.0)*4.0/width;
    half x = 0, y = 0;
    int iteration = 0;
    while (x*x+y*y <= 4 && iteration < ITERATION_MAX) {
        half x_new = x*x - y*y + c_re;
        y = 2*x*y + c_im;
        x = x_new;
        iteration++;
    }
    if (iteration < ITERATION_MAX) {
        int increase = iteration;

        out.x = randomR * increase;  /* red */
        out.y = randomG * increase;   /* green */
        out.z = randomB * increase;  /* blue */
        return out;
    }
        //write black to "void:"
        return black;
    
    
  

}

