//
//  common.metal
//  MetalResize
//
//  Created by 谢宜 on 2018/1/22.
//  Copyright © 2018年 谢宜. All rights reserved.
//

#include "common.hpp"

float4 GetPixelClamped(texture2d<float, access::read> in [[texture(0)]], uint x, uint y) {
    CLAMP(x, 0, inW - 1)
    CLAMP(y, 0, inH - 1)
    return in.read(uint2(x, y));
}

