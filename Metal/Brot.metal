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

typedef enum {
    black, red, orange, yellow, green, blue, indigo, violet
} LinearColor;

// Color scheme 1: Classic Rainbow
float4 colorFromUInt_rainbow(LinearColor color) {
    switch (color) {
        case red: return {1.0, 0.0, 0.0, 1};
        case orange: return {1.0, 0.5, 0.0, 1};
        case yellow: return {1.0, 1.0, 0.0, 1};
        case green: return {0.0, 1.0, 0.0, 1};
        case blue: return {0.0, 0.0, 1.0, 1};
        case indigo: return {0.5, 0.0, 1.0, 1};
        case violet: return {1.0, 0.0, 1.0, 1};
        case black: return {0, 0, 0, 1};
    }
    return {1, 1, 1, 1};
}

// Color scheme 2: Warm Sunset
float4 colorFromUInt_sunset(LinearColor color) {
    switch (color) {
        case red: return {0.8, 0.2, 0.1, 1};
        case orange: return {0.9, 0.4, 0.2, 1};
        case yellow: return {1.0, 0.6, 0.3, 1};
        case green: return {0.7, 0.5, 0.2, 1};
        case blue: return {0.4, 0.3, 0.6, 1};
        case indigo: return {0.3, 0.2, 0.5, 1};
        case violet: return {0.5, 0.1, 0.4, 1};
        case black: return {0, 0, 0, 1};
    }
    return {1, 1, 1, 1};
}

// Color scheme 3: Cool Ocean
float4 colorFromUInt_ocean(LinearColor color) {
    switch (color) {
        case red: return {0.1, 0.3, 0.5, 1};
        case orange: return {0.2, 0.4, 0.6, 1};
        case yellow: return {0.3, 0.5, 0.7, 1};
        case green: return {0.4, 0.6, 0.8, 1};
        case blue: return {0.5, 0.7, 0.9, 1};
        case indigo: return {0.3, 0.5, 0.8, 1};
        case violet: return {0.2, 0.4, 0.7, 1};
        case black: return {0, 0, 0, 1};
    }
    return {1, 1, 1, 1};
}

// Original function (keeping for reference)
float4 colorFromUInt(LinearColor color) {
    switch (color) {
        case red: return {1.0, 0.149, 0, 1};
        case orange: return {0.968, 0.524, 0.291, 1};
        case yellow: return {0.998, 1, 0.625, 1};
        case green: return {0.626, 0.835, 0.242, 1};
        case blue: return {0, 0.748, 1, 1};
        case indigo: return {0.324, 0.106, 0.575, 1};
        case violet: return {1.0, 0, 1, 1};
        case black: return {0, 0, 0, 1};
    }
    return {1, 1, 1, 1};
}

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
    
    // Use the passed color scheme instead of random selection
    float4 color;
    
    switch (in.colorScheme) {
        case 0:
            color = colorFromUInt_rainbow((LinearColor)(uint)iteration);
            break;
        case 1:
            color = colorFromUInt_sunset((LinearColor)(uint)iteration);
            break;
        case 2:
            color = colorFromUInt_ocean((LinearColor)(uint)iteration);
            break;
        default:
            color = colorFromUInt((LinearColor)(uint)iteration);
            break;
    }
    
    // Blend the calculated color with the passed-in base color
    fragOut.color = (iteration < ITERATION_MAX) ? mix(in.color, color, 0.8) : black;
    
    return fragOut;
}
