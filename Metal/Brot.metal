//
//  Brot.metal
//  Metalbrot
//

#include "MetalHeaders.h"
#include <TargetConditionals.h>

#if TARGET_OS_TV
#define ITERATION_MAX 200
#else
#define ITERATION_MAX 100
#endif

typedef enum {
    VertexIndex,
    ViewportSizeIndex,
    OriginIndex,
    ZoomRectIndex,
    BaseColorIndex
} MetalbrotBufferIndex;

using namespace metal;

#include "Shared/MandelbrotCore.metal"

vertex BrotVertexOut brot_vertex_main(BrotVertexIn vertex_in [[stage_in]],
                                     constant vector_uint2 *viewportSizePointer [[buffer(ViewportSizeIndex)]],
                                     constant vector_int2 *originPointer [[buffer(OriginIndex)]],
                                     constant vector_float2 *zoomPointer [[buffer(ZoomRectIndex)]],
                                     constant vector_float4 *color [[buffer(BaseColorIndex)]],
                                     constant uint *colorScheme [[buffer(5)]]) {
    BrotVertexOut out;
    out.position = float4(vertex_in.position, 0.0, 1.0);
    out.viewportSize = *viewportSizePointer;
    out.origin = *originPointer;
    out.zoom = *zoomPointer;
    out.color = *color;
    out.colorScheme = *colorScheme;
    return out;
}

fragment FragmentOut brot_fragment_main(BrotVertexOut in [[stage_in]]) {
    FragmentOut fragOut;
    float4 black = float4(0, 0, 0, 1);
    
    const float width = in.viewportSize.x;
    const float height = in.viewportSize.y;
    const float pxXScaleFactor = width / in.zoom.x;
    const float pxYScaleFactor = height / in.zoom.y;
    
    const float adjustedPixX = ((in.position.x / width) * (in.zoom.x * pxXScaleFactor)) + (in.origin.x * pxXScaleFactor);
    const float adjustedPixY = ((in.position.y / height) * (in.zoom.y * pxYScaleFactor)) + (in.origin.y * pxYScaleFactor);
    
    const float adjustedWidth = width * pxXScaleFactor;
    const float adjustedHeight = height * pxYScaleFactor;
    
    const float c_re = (adjustedPixX - adjustedWidth/2.0) * 4.0/adjustedWidth;
    const float c_im = (adjustedPixY - adjustedHeight/2.0) * 4.0/adjustedWidth;
    
    float2 c = float2(c_re, c_im);
    float smoothIteration = mandelbrotSmoothIter(c, ITERATION_MAX);
    float zoomLevel = in.zoom.x / width;
    float4 color = mandelbrotColor(smoothIteration, zoomLevel, in.colorScheme, ITERATION_MAX);
    
    // Blend the calculated color with the passed-in base color
    fragOut.color = (smoothIteration < ITERATION_MAX) ? mix(in.color, color, 0.8) : black;
    
    return fragOut;
}
