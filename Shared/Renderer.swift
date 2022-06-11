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
    
    //use semaphore to synchronize CPU and GPU work?
    let semaphore = DispatchSemaphore(value: 0)
    
    lazy var vertexBuffer = {
        device.makeBuffer(bytes: gon2, length: gon2.count * MemoryLayout<BasicVertex>.stride, options: [])!
    }()
    
    lazy var viewPortBuffer = {
        device.makeBuffer(length: MemoryLayout<vector_uint2>.stride)
    }()
    
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
    
    var gon2: [BasicVertex]
    
    init(device: MTLDevice,view:MTKView){
        
        gon2 = gon.map({
            BasicVertex(position: $0.position)
        })
        
        self.device = device
        self.library = device.makeDefaultLibrary()!
        self.commandQueue = device.makeCommandQueue()!
        
        self.view = view
        view.preferredFramesPerSecond = 30
        view.clearColor = UIColor.systemBlue.metalClearColor()
        
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
        
        descriptor.vertexDescriptor = vertexDescriptor
        //
        //        view.enableSetNeedsDisplay = false
        //        view.isPaused = true
        
        pipelineState = try! device.makeRenderPipelineState(descriptor: descriptor)
        
        
        
        super.init()
        view.delegate = self
        //render()
    }
    
    func render(view: MTKView){
        
        guard let descriptor = view.currentRenderPassDescriptor,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            fatalError()
        }
        
        let size = view.drawableSize
        var viewportSize: vector_uint2 = vector_uint2(x: UInt32(size.width), y: UInt32(size.height))
        viewPortBuffer = device.makeBuffer(bytes: &viewportSize, length: MemoryLayout.size(ofValue: viewportSize))
        
        
        //
        renderEncoder.setRenderPipelineState(pipelineState)
        
        //begin actual drawing code
        
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(viewPortBuffer, offset:0, index: 1)
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        

        //END actual draw code
        
        if let drawable = view.currentDrawable {
            
            //            commandBuffer.addCompletedHandler { [weak self] buffer in
            //                //self?.semaphore.signal()
            //            }
            //commandBuffer.present(drawable, afterMinimumDuration: Double(view.preferredFramesPerSecond))
            renderEncoder.endEncoding()
            commandBuffer.present(drawable)
            commandBuffer.commit()
            commandBuffer.waitUntilCompleted()
            //semaphore.wait(timeout: .distantFuture)
            
        }
        
        
        
    }
    
}

//MARK: Metal Kit
extension Renderer: MTKViewDelegate {
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        print("drawable size now \(size)")
        //       render(view: view)
    }
    
    func draw(in view: MTKView) {
        render(view: view)
    }
}
