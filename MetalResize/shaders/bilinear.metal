//
//  bilinear.metal
//  MetalResize
//
//  Created by 谢宜 on 2018/1/22.
//  Copyright © 2018年 谢宜. All rights reserved.
//
//  Reference: https://blog.demofox.org/2015/08/15/resizing-images-with-bicubic-interpolation/

#include "common.hpp"

float Lerp (float A, float B, float t) {
    return A * (1.0f - t) + B * t;
}

float4 SampleBilinear (texture2d<float, access::read> in [[texture(0)]], float u, float v) {
    // calculate coordinates -> also need to offset by half a pixel to keep image from shifting down and left half a pixel
    float x = u * float(inW) - 0.5f;
    int xint = int(x);
    float xfract = x - floor(x);
    
    float y = v * float(inH) - 0.5f;
    int yint = int(y);
    float yfract = y - floor(y);
    
    // get pixels
    auto p00 = GetPixelClamped(in, xint + 0, yint + 0);
    auto p10 = GetPixelClamped(in, xint + 1, yint + 0);
    auto p01 = GetPixelClamped(in, xint + 0, yint + 1);
    auto p11 = GetPixelClamped(in, xint + 1, yint + 1);
    
    // interpolate bi-linearly!
    float4 ret;
    for (int i = 0; i < 4; ++i)
    {
        float col0 = Lerp(p00[i], p10[i], xfract);
        float col1 = Lerp(p01[i], p11[i], xfract);
        float value = Lerp(col0, col1, yfract);
        CLAMP(value, 0.0f, 255.0f);
        ret[i] = value;
    }
    return ret;
}

kernel void BilinearMain(texture2d<float, access::read> in  [[texture(0)]],
                        texture2d<float, access::write> out [[texture(1)]],
                        uint2 gid [[thread_position_in_grid]]) {
    float v = float(gid.y) / float(outH - 1);
    float u = float(gid.x) / float(outW - 1);
    out.write(SampleBilinear(in, u, v), gid);
}
