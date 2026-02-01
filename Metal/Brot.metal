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

#include "Palette.metal"

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
    
    float x = 0, y = 0;
    uint iteration = 0;
    
    while (x*x + y*y <= 4 && iteration < ITERATION_MAX) {
        float x_new = x*x - y*y + c_re;
        y = 2*x*y + c_im;
        x = x_new;
        iteration++;
    }
    
    float smoothIteration = (float)iteration;
    if (iteration < ITERATION_MAX) {
        float modulus = x * x + y * y;
        float log_zn = log2(modulus) / 2.0;
        float nu = log2(log_zn);
        smoothIteration = (float)iteration + 1.0 - nu;
    }
    
    float zoomLevel = in.zoom.x / width;
    float zoomBoost = clamp(log2(zoomLevel + 1.0), 0.0, 6.0);
    float cycles = 0.08 + (zoomBoost * 0.05);
    float t = fract(smoothIteration * cycles);
    
    float4 color = paletteSample(in.colorScheme, t);
    
    // Blend the calculated color with the passed-in base color
    fragOut.color = (iteration < ITERATION_MAX) ? mix(in.color, color, 0.8) : black;
    
    return fragOut;
}
