//
//  common.hpp
//  MetalResize
//
//  Created by 谢宜 on 2018/1/22.
//  Copyright © 2018年 谢宜. All rights reserved.
//

#pragma once
#include <metal_stdlib>
using namespace metal;

constant float factor [[function_constant(0)]];
constant uint  inW    [[function_constant(1)]];
constant uint  inH    [[function_constant(2)]];
constant uint  outW   [[function_constant(3)]];
constant uint  outH   [[function_constant(4)]];
constant uint  outP   [[function_constant(5)]];

#define CLAMP(v, min, max) \
    if (v < min) { \
        v = min; \
    } else if (v > max) { \
        v = max; \
    }

float4 GetPixelClamped(texture2d<float, access::read> in [[texture(0)]], uint x, uint y);
