//
//  nearest.metal
//  MetalResize
//
//  Created by 谢宜 on 2018/1/22.
//  Copyright © 2018年 谢宜. All rights reserved.
//
//  Reference: https://blog.demofox.org/2015/08/15/resizing-images-with-bicubic-interpolation/

#include "common.hpp"

float4 SampleNearest(texture2d<float, access::read> in [[texture(0)]], float u, float v) {
    // calculate coordinates
    int xint = int(u * float(inW));
    int yint = int(v * float(inH));
    
    // return pixel
    return GetPixelClamped(in, xint, yint);
}

kernel void NearestMain(texture2d<float, access::read> in  [[texture(0)]],
                         texture2d<float, access::write> out [[texture(1)]],
                         uint2 gid [[thread_position_in_grid]]) {
    float v = float(gid.y) / float(outH - 1);
    float u = float(gid.x) / float(outW - 1);
    out.write(SampleNearest(in, u, v), gid);
}
