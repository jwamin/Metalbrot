#ifndef MANDELBROT_CORE_METAL
#define MANDELBROT_CORE_METAL

#include <metal_stdlib>
using namespace metal;

#include "../Palette.metal"

inline float mandelbrotSmoothIter(float2 c, uint maxIter) {
    float x = 0.0f;
    float y = 0.0f;
    uint iteration = 0;
    while ((x * x + y * y <= 4.0f) && (iteration < maxIter)) {
        float x_new = x * x - y * y + c.x;
        y = 2.0f * x * y + c.y;
        x = x_new;
        iteration++;
    }

    float smoothIter = (float)iteration;
    if (iteration < maxIter) {
        float modulus = x * x + y * y;
        float log_zn = log2(modulus) / 2.0f;
        float nu = log2(log_zn);
        smoothIter = (float)iteration + 1.0f - nu;
    }

    return smoothIter;
}

inline float mandelbrotColorT(float smoothIter, float scale) {
    float zoomBoost = clamp(log2(1.0f / max(scale, 1.0e-6f)), 0.0f, 8.0f);
    float cycles = 0.08f + (zoomBoost * 0.05f);
    return fract(smoothIter * cycles);
}

inline float4 mandelbrotColor(float smoothIter, float scale, uint scheme, uint maxIter) {
    if (smoothIter >= (float)maxIter) {
        return float4(0, 0, 0, 1);
    }

    float t = mandelbrotColorT(smoothIter, scale);
    return paletteSample(scheme, t);
}

#endif
