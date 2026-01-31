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

// Color scheme 0: Classic Rainbow
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

// Color scheme 1: Warm Sunset
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

// Color scheme 2: Cool Ocean
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

// Color scheme 3: Forest Moss
float4 colorFromUInt_forest(LinearColor color) {
    switch (color) {
        case red: return {0.2, 0.3, 0.1, 1};
        case orange: return {0.3, 0.4, 0.15, 1};
        case yellow: return {0.4, 0.5, 0.2, 1};
        case green: return {0.1, 0.6, 0.2, 1};
        case blue: return {0.1, 0.3, 0.4, 1};
        case indigo: return {0.15, 0.25, 0.35, 1};
        case violet: return {0.2, 0.2, 0.3, 1};
        case black: return {0, 0, 0, 1};
    }
    return {1, 1, 1, 1};
}

// Color scheme 4: Neon Vapor
float4 colorFromUInt_neon(LinearColor color) {
    switch (color) {
        case red: return {1.0, 0.0, 0.6, 1};
        case orange: return {1.0, 0.2, 0.3, 1};
        case yellow: return {0.9, 0.8, 0.2, 1};
        case green: return {0.2, 1.0, 0.6, 1};
        case blue: return {0.0, 0.6, 1.0, 1};
        case indigo: return {0.4, 0.2, 1.0, 1};
        case violet: return {0.8, 0.0, 1.0, 1};
        case black: return {0, 0, 0, 1};
    }
    return {1, 1, 1, 1};
}

// Color scheme 5: Desert Heat
float4 colorFromUInt_desert(LinearColor color) {
    switch (color) {
        case red: return {0.9, 0.35, 0.1, 1};
        case orange: return {0.95, 0.5, 0.15, 1};
        case yellow: return {1.0, 0.7, 0.3, 1};
        case green: return {0.75, 0.6, 0.25, 1};
        case blue: return {0.45, 0.35, 0.3, 1};
        case indigo: return {0.35, 0.25, 0.35, 1};
        case violet: return {0.5, 0.2, 0.4, 1};
        case black: return {0, 0, 0, 1};
    }
    return {1, 1, 1, 1};
}

// Color scheme 6: Ice Blue
float4 colorFromUInt_ice(LinearColor color) {
    switch (color) {
        case red: return {0.75, 0.9, 1.0, 1};
        case orange: return {0.6, 0.85, 1.0, 1};
        case yellow: return {0.45, 0.8, 1.0, 1};
        case green: return {0.3, 0.7, 0.95, 1};
        case blue: return {0.2, 0.6, 0.9, 1};
        case indigo: return {0.2, 0.5, 0.8, 1};
        case violet: return {0.2, 0.4, 0.7, 1};
        case black: return {0, 0, 0, 1};
    }
    return {1, 1, 1, 1};
}

// Color scheme 7: Plasma
float4 colorFromUInt_plasma(LinearColor color) {
    switch (color) {
        case red: return {0.2, 0.0, 0.3, 1};
        case orange: return {0.35, 0.0, 0.6, 1};
        case yellow: return {0.6, 0.0, 0.8, 1};
        case green: return {0.85, 0.2, 0.6, 1};
        case blue: return {1.0, 0.45, 0.2, 1};
        case indigo: return {1.0, 0.7, 0.1, 1};
        case violet: return {0.95, 0.85, 0.2, 1};
        case black: return {0, 0, 0, 1};
    }
    return {1, 1, 1, 1};
}

// Color scheme 8: Aurora
float4 colorFromUInt_aurora(LinearColor color) {
    switch (color) {
        case red: return {0.05, 0.2, 0.3, 1};
        case orange: return {0.0, 0.35, 0.45, 1};
        case yellow: return {0.0, 0.55, 0.6, 1};
        case green: return {0.0, 0.75, 0.5, 1};
        case blue: return {0.2, 0.9, 0.4, 1};
        case indigo: return {0.45, 0.95, 0.6, 1};
        case violet: return {0.65, 0.9, 0.8, 1};
        case black: return {0, 0, 0, 1};
    }
    return {1, 1, 1, 1};
}

// Color scheme 9: Monochrome Blue
float4 colorFromUInt_monochromeBlue(LinearColor color) {
    switch (color) {
        case red: return {0.05, 0.1, 0.2, 1};
        case orange: return {0.1, 0.2, 0.35, 1};
        case yellow: return {0.15, 0.3, 0.5, 1};
        case green: return {0.2, 0.4, 0.65, 1};
        case blue: return {0.25, 0.5, 0.8, 1};
        case indigo: return {0.35, 0.65, 0.9, 1};
        case violet: return {0.45, 0.8, 1.0, 1};
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

float4 paletteColorByScheme(uint scheme, LinearColor color) {
    switch (scheme) {
        case 0:
            return colorFromUInt_rainbow(color);
        case 1:
            return colorFromUInt_sunset(color);
        case 2:
            return colorFromUInt_ocean(color);
        case 3:
            return colorFromUInt_forest(color);
        case 4:
            return colorFromUInt_neon(color);
        case 5:
            return colorFromUInt_desert(color);
        case 6:
            return colorFromUInt_ice(color);
        case 7:
            return colorFromUInt_plasma(color);
        case 8:
            return colorFromUInt_aurora(color);
        case 9:
            return colorFromUInt_monochromeBlue(color);
        default:
            return colorFromUInt(color);
    }
}

float4 paletteSample(uint scheme, float t) {
    float clamped = clamp(t, 0.0f, 1.0f);
    float scaled = clamped * 7.0f;
    uint idx = (uint)floor(scaled);
    float frac = scaled - (float)idx;
    LinearColor c0 = (LinearColor)idx;
    LinearColor c1 = (LinearColor)min(idx + 1, 7u);
    float4 col0 = paletteColorByScheme(scheme, c0);
    float4 col1 = paletteColorByScheme(scheme, c1);
    return mix(col0, col1, frac);
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
