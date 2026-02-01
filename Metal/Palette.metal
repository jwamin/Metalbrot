#include <metal_stdlib>
using namespace metal;

typedef enum {
    black, red, orange, yellow, green, blue, indigo, violet
} LinearColor;

inline float4 colorFromUInt_rainbow(LinearColor color) {
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

inline float4 colorFromUInt_sunset(LinearColor color) {
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

inline float4 colorFromUInt_ocean(LinearColor color) {
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

inline float4 colorFromUInt_forest(LinearColor color) {
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

inline float4 colorFromUInt_neon(LinearColor color) {
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

inline float4 colorFromUInt_desert(LinearColor color) {
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

inline float4 colorFromUInt_ice(LinearColor color) {
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

inline float4 colorFromUInt_plasma(LinearColor color) {
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

inline float4 colorFromUInt_aurora(LinearColor color) {
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

inline float4 colorFromUInt_monochromeBlue(LinearColor color) {
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

inline float4 paletteColorByScheme(uint scheme, LinearColor color) {
    switch (scheme) {
        case 0: return colorFromUInt_rainbow(color);
        case 1: return colorFromUInt_sunset(color);
        case 2: return colorFromUInt_ocean(color);
        case 3: return colorFromUInt_forest(color);
        case 4: return colorFromUInt_neon(color);
        case 5: return colorFromUInt_desert(color);
        case 6: return colorFromUInt_ice(color);
        case 7: return colorFromUInt_plasma(color);
        case 8: return colorFromUInt_aurora(color);
        case 9: return colorFromUInt_monochromeBlue(color);
        default: return colorFromUInt_rainbow(color);
    }
}

inline float4 paletteSample(uint scheme, float t) {
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
