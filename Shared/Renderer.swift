//
//  Renderer.swift
//  MetalFromTheTop
//
//  Created by Joss Manger on 11/24/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import MetalKit

class Renderer: NSObject {
    
    let device:MTLDevice
    unowned let view:MTKView
    let library:MTLLibrary
    let descriptor:MTLRenderPipelineDescriptor
    let pipelineState:MTLRenderPipelineState
    let commandQueue:MTLCommandQueue
    
    typealias Blob = (Float,Float,Float,Float,Float,Float)
    
    struct ColoredVertex{
        
        let position:SIMD2<Float>
        let color:SIMD4<Float>
        
        init(with blob:Blob) {
            position = [blob.0,blob.1]
            color = [blob.2,blob.3,blob.4,blob.5]
        }
        
        
    }
    
    struct BasicVertex {
        
        let position:SIMD2<Float>
        
    }
    
    let gon:[ColoredVertex] = [
        ColoredVertex(with:(-1.0,-1.0,1.0,0.0,0.0,1.0)), // r
        ColoredVertex(with:(-1.0,1.0,0.0,0.0,1.0,1.0)), //b
        ColoredVertex(with:(1.0,-1.0,1.0,1.0,1.0,1.0)), //w
        ColoredVertex(with:(1.0,1.0,0.0,1.0,0.0,1.0)), //g
        
        
    ]
    
    init(device: MTLDevice,view:MTKView){
        
        self.device = device
        self.library = device.makeDefaultLibrary()!
        self.commandQueue = device.makeCommandQueue()!
        
        self.view = view
        let clearColor = UIColor.systemBlue.metalClearColor()
        view.clearColor = clearColor
        
        let vertexFunction = library.makeFunction(name: "brot_vertex_main")
        let fragmentFunction = library.makeFunction(name: "brot_fragment_main")
        
        descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = vertexFunction
        
        descriptor.fragmentFunction = fragmentFunction
        descriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        
        
        
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float2
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.layouts[0].stride = MemoryLayout<BasicVertex>.stride
        
        vertexDescriptor.attributes[1].format = .uint2
        vertexDescriptor.attributes[1].offset = 0
        vertexDescriptor.attributes[1].bufferIndex = 1
        vertexDescriptor.layouts[1].stride = MemoryLayout<vector_uint2>.stride
        
        
//        vertexDescriptor.attributes[2].format = .float4
//        vertexDescriptor.attributes[2].offset = MemoryLayout<SIMD4<Float>>.stride
//        vertexDescriptor.attributes[2].bufferIndex = 2
//        vertexDescriptor.layouts[2].stride = MemoryLayout<VertexWithWH>.stride
        
        descriptor.vertexDescriptor = vertexDescriptor
        
        pipelineState = try! device.makeRenderPipelineState(descriptor: descriptor)
        super.init()
        view.delegate = self
        
    }
    
    func render(){
        
        guard let descriptor = view.currentRenderPassDescriptor,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            fatalError()
        }
        
        //begin actual drawing code
        //let wh:SIMD2<Float> = [Float(view.bounds.width),Float(view.bounds.height)]
        var newGon = gon.map({
            BasicVertex(position: $0.position)
        })
        
        
        let buffer = device.makeBuffer(bytes: newGon, length: newGon.count * MemoryLayout<BasicVertex>.stride, options: [])!
        
        var viewportSize: vector_uint2 = vector_uint2(x: UInt32(view.drawableSize.width), y: UInt32(view.drawableSize.height))
        
        //
        renderEncoder.setRenderPipelineState(pipelineState)
        //renderEncoder.setVertexBytes(&newGon, length: newGon.count * MemoryLayout<BasicVertex>.stride, index: 0)
        renderEncoder.setVertexBuffer(buffer, offset: 0, index: 0)
        renderEncoder.setVertexBytes(&viewportSize, length: MemoryLayout<vector_uint2>.stride, index: 1)
//        renderEncoder.setVertexBuffer(buffer, offset: 0, index: 1)
//        renderEncoder.setVertexBuffer(buffer, offset: 0, index: 2)
        
        //renderEncoder.drawIndexedPrimitives(type: .triangle, indexCount: 1, indexType: .uint16, indexBuffer: buffer, indexBufferOffset: 0)
        
        //END actual draw code
        
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        renderEncoder.endEncoding()
        
        if let drawable = view.currentDrawable?.layer.nextDrawable() {
            commandBuffer.present(drawable)
            commandBuffer.commit()
            
        }
        
    }
    
}

//MARK: Metal Kit
extension Renderer: MTKViewDelegate {
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
     print("drawable size now \(size)")
        render()
    }
    
    func draw(in view: MTKView) {
        render()
    }
}
