//
//  MetalHeaders.h
//  Metalbrot
//
//  Created by Joss Manger on 6/11/22.
//

#ifndef MetalHeaders_h
#define MetalHeaders_h

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
  float2 position [[ attribute(0) ]];
  float4 color [[ attribute(1) ]]; // i litterally swapped these around and it worked correctly
};

struct VertexOut {
  float4 position [[ position ]]; // [[position]] appears to be some magic thing that tells the compiler this attribute will provide the vertex data
  float4 color;
};

struct BrotVertexIn {
    float2 position [[ attribute(0) ]];
    float2 origin [[ attribute (2) ]];
};

struct BrotVertexOut {
    float4 position [[ position ]];
    float2 viewportSize;
    float4 color [[ flat ]];
    float2 origin;
    float2 zoom;
    float vAdjust;
};

#endif /* MetalHeaders_h */
