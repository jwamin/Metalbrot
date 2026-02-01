#include <metal_stdlib>
using namespace metal;

#include "../Metal/Palette.metal"

struct VertexIn {
    float2 position [[attribute(0)]];
    float2 uv [[attribute(1)]];
};

struct VertexOut {
    float4 position [[position]];
    float2 uv;
};

struct Params {
    float2 center;
    float scale;
    uint maxIter;
    uint colorScheme;
    uint pad0;
    uint2 viewport;
};

vertex VertexOut mbrot_vertex_main(VertexIn in [[stage_in]]) {
    VertexOut out;
    out.position = float4(in.position, 0.0, 1.0);
    out.uv = in.uv;
    return out;
}

struct IterOut {
    float value [[color(0)]];
};

fragment IterOut mbrot_iter_fragment(VertexOut in [[stage_in]],
                                    constant Params &params [[buffer(0)]]) {
    IterOut out;
    uint safeMaxIter = max(params.maxIter, 1u);
    float aspect = (float)params.viewport.y / max((float)params.viewport.x, 1.0f);
    float2 c;
    c.x = params.center.x + (in.uv.x - 0.5f) * params.scale * 2.0f;
    c.y = params.center.y + (in.uv.y - 0.5f) * params.scale * 2.0f * aspect;

    float x = 0.0f;
    float y = 0.0f;
    uint iteration = 0;
    while ((x * x + y * y <= 4.0f) && (iteration < safeMaxIter)) {
        float x_new = x * x - y * y + c.x;
        y = 2.0f * x * y + c.y;
        x = x_new;
        iteration++;
    }

    float smoothIter = (float)iteration;
    if (iteration < safeMaxIter) {
        float modulus = x * x + y * y;
        float log_zn = log2(modulus) / 2.0f;
        float nu = log2(log_zn);
        smoothIter = (float)iteration + 1.0f - nu;
    }

    float normalized = smoothIter / (float)safeMaxIter;
    out.value = clamp(normalized, 0.0f, 1.0f);
    return out;
}

fragment float4 mbrot_color_fragment(VertexOut in [[stage_in]],
                                    texture2d<float, access::sample> iterTex [[texture(0)]],
                                    constant Params &params [[buffer(0)]]) {
    constexpr sampler s(coord::normalized, address::clamp_to_edge, filter::nearest);
    float iterNorm = (float)iterTex.sample(s, in.uv).r;
    if (iterNorm >= 1.0f) {
        return float4(0, 0, 0, 1);
    }

    float zoomBoost = clamp(log2(1.0f / max(params.scale, 1.0e-6f)), 0.0f, 8.0f);
    float cycles = 0.08f + (zoomBoost * 0.05f);
    float t = fract(iterNorm * cycles);
    float4 color = paletteSample(params.colorScheme, t);
    return color;
}
