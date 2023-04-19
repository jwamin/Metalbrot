//
//  MetalbrotRenderer.swift
//  Metalbrot
//
//  Created by Joss Manger on 11/24/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import MetalKit

class MetalbrotRenderer: NSObject {
    
    let device:MTLDevice
    unowned let view:MTKView
    let library:MTLLibrary
    let descriptor:MTLRenderPipelineDescriptor
    let pipelineState:MTLRenderPipelineState
    let commandQueue:MTLCommandQueue
    
    //use semaphore to synchronize CPU and GPU work?
    let semaphore = DispatchSemaphore(value: 0)
    
    lazy var vertexBuffer: MTLBuffer = {
        let gon2 = gon.map({
            BasicVertex(position: $0.position)
        })
        return device.makeBuffer(bytes: gon2, length: gon2.count * MemoryLayout<BasicVertex>.stride, options: [])!
    }()
    
    lazy var getBuffers = {
        (device.makeBuffer(length: MemoryLayout<vector_uint2>.stride),
         device.makeBuffer(length: MemoryLayout<vector_uint2>.stride))
    }()
    
    init(device: MTLDevice,view:MTKView){
        
        self.device = device
        self.library = device.makeDefaultLibrary()!
        self.commandQueue = device.makeCommandQueue()!
        
        self.view = view
        //view.preferredFramesPerSecond = 30
        view.clearColor = Color.systemBlue.metalClearColor()
        
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
        
        vertexDescriptor.attributes[2].format = .uint2
        vertexDescriptor.attributes[2].offset = 0
        vertexDescriptor.attributes[2].bufferIndex = 2
        vertexDescriptor.layouts[2].stride = MemoryLayout<vector_uint2>.stride
        
        descriptor.vertexDescriptor = vertexDescriptor
        
        view.enableSetNeedsDisplay = true
        view.isPaused = true
        
        pipelineState = try! device.makeRenderPipelineState(descriptor: descriptor)
        
        super.init()
        view.delegate = self

    }
    
    func render(view: MTKView, originSize: (Int,Int)?){
        
        guard let descriptor = view.currentRenderPassDescriptor,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            fatalError()
        }
        let origin2 = originSize ?? (0,0)
        let origin: vector_uint2 = vector_uint2(x: UInt32(origin2.0), y: UInt32(origin2.1))
        let (viewportBuffer, originBuffer) = getBuffers
        let size = view.drawableSize
        let viewportSize: vector_uint2 = vector_uint2(x: UInt32(size.width), y: UInt32(size.height))
        let sizePtr = viewportBuffer?.contents()
        sizePtr?.storeBytes(of: viewportSize, as: vector_uint2.self)
        
        let originPtr = originBuffer?.contents()
        originPtr?.storeBytes(of: origin, as: vector_uint2.self)
        
        renderEncoder.setRenderPipelineState(pipelineState)
        
        //begin actual drawing code
        
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(viewportBuffer, offset:0, index: 1)
        renderEncoder.setVertexBuffer(originBuffer, offset: 0, index: 2)
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
    
        //END actual draw code
        
        if let drawable = view.currentDrawable {
            
            renderEncoder.endEncoding()
            commandBuffer.present(drawable)
            commandBuffer.commit()
            commandBuffer.waitUntilCompleted()
            
        }
        
    }
    
    var customSize: CGPoint? = nil
    
}

//MARK: Metal Kit
extension MetalbrotRenderer: MTKViewDelegate {
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        view.setNeedsDisplay(.init(origin: .zero, size: size))
    }
    
    func updateZoomArea(_ newSize: CGPoint){
        customSize = newSize
        view.setNeedsDisplay(.init(origin: .zero, size: view.drawableSize))
    }
    
    func draw(in view: MTKView) {
        var tuple = (Int(customSize?.x ?? 0),Int(customSize?.y ?? 0))
        tuple = (max(tuple.0, 0),max(tuple.1, 0))
        render(view: view,originSize: tuple)
    }
    
}
