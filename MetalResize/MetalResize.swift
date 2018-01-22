//
//  MetalResize.swift
//  MetalResize
//
//  Created by 谢宜 on 2018/1/22.
//  Copyright © 2018年 谢宜. All rights reserved.
//

import Foundation
import Metal
import MetalKit

public enum InterpolationType: String {
    case nearest = "NearestMain"
    case bilinear = "BilinearMain"
    case bicubic = "BicubicMain"
}

open class MetalResize {
    
    let device: MTLDevice!
    let library: MTLLibrary!
    let commandQueue: MTLCommandQueue!
    
    public init() throws {
        device = MTLCreateSystemDefaultDevice()
        library = try device.makeDefaultLibrary(bundle: Bundle(for: type(of: self)))
        commandQueue = device.makeCommandQueue()
    }
    
    open func resize(_ input: UIImage, _ factor: Float = 1.0, _ type: InterpolationType = .bicubic) -> UIImage? {
        // Get image size
        guard let imgRef = input.cgImage else {
            return nil
        }
        var inW = imgRef.width
        var inH = imgRef.height
        var sf = factor
        // Get raw image data
        let bitsPerComponent = imgRef.bitsPerComponent
        let bitsPerPixel = imgRef.bitsPerPixel
        let bytesPerPixel = bitsPerPixel / bitsPerComponent
        let bytesPerRow = bytesPerPixel * inW
        var inRaw = [UInt8](repeating: 0, count: inW * inH * bytesPerPixel)
        let bitmapInfo = CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: &inRaw, width: inW, height: inH, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
        context?.draw(imgRef, in: CGRect(origin: .zero, size: CGSize(width: inW, height: inH)))
        // Convert to metal texture
        let inTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: MTLPixelFormat.rgba8Unorm, width: inW, height: inH, mipmapped: true)
        let inTexture = device.makeTexture(descriptor: inTextureDescriptor)
        let inRegion = MTLRegionMake2D(0, 0, inW, inH)
        inTexture?.replace(region: inRegion, mipmapLevel: 0, withBytes: &inRaw, bytesPerRow: bytesPerRow)
        // Prepare output texture
        var outW = Int(Float(inW) * factor)
        var outH = Int(Float(inH) * factor)
        var outP = outW * bytesPerPixel
        let outTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: MTLPixelFormat.rgba8Unorm, width: outW, height: outH, mipmapped: false)
        guard let outTexture = device.makeTexture(descriptor: outTextureDescriptor) else {
            return nil
        }
        // Set constants
        let constants = MTLFunctionConstantValues()
        constants.setConstantValue(&sf,   type: MTLDataType.float, index: 0)
        constants.setConstantValue(&inW,  type: MTLDataType.uint,  index: 1)
        constants.setConstantValue(&inH,  type: MTLDataType.uint,  index: 2)
        constants.setConstantValue(&outW, type: MTLDataType.uint,  index: 3)
        constants.setConstantValue(&outH, type: MTLDataType.uint,  index: 4)
        constants.setConstantValue(&outP, type: MTLDataType.uint,  index: 5)
        let sampleMain = try! library.makeFunction(name: type.rawValue, constantValues: constants)
        let pipelineState = try! device.makeComputePipelineState(function: sampleMain)
        // Invoke kernel function
        let commandBuffer = commandQueue.makeCommandBuffer()
        let commandEncoder = commandBuffer?.makeComputeCommandEncoder()
        commandEncoder?.setComputePipelineState(pipelineState)
        commandEncoder?.setTexture(inTexture, index: 0)
        commandEncoder?.setTexture(outTexture, index: 1)
        let threadGroupCount = MTLSize(width: 1, height: 1, depth: 1)
        let threadGroups = MTLSize(width: outW / threadGroupCount.width, height: outH / threadGroupCount.height, depth: 1)
        commandEncoder?.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupCount)
        commandEncoder?.endEncoding()
        commandBuffer?.commit()
        commandBuffer?.waitUntilCompleted()
        // Get output texture
        let outByteCount = outW * outH * 4
        let outBytesPerRow = bytesPerPixel * outW
        var outBytes = [UInt8](repeating: 0, count: outByteCount)
        let outRegion = MTLRegionMake2D(0, 0, outW, outH)
        outTexture.getBytes(&outBytes, bytesPerRow: outBytesPerRow, from: outRegion, mipmapLevel: 0)
        // Convert it to image
        guard let outProvider = CGDataProvider(data: NSData(bytes: &outBytes, length: outByteCount * MemoryLayout<UInt8>.size)) else {
            return nil
        }
        guard let outRef = CGImage(width: outW, height: outH, bitsPerComponent: bitsPerComponent, bitsPerPixel: bitsPerPixel, bytesPerRow: outBytesPerRow, space: colorSpace, bitmapInfo: CGBitmapInfo(rawValue: bitmapInfo), provider: outProvider, decode: nil, shouldInterpolate: false, intent: CGColorRenderingIntent.defaultIntent) else {
            return nil
        }
        return UIImage(cgImage: outRef)
    }
    
}

