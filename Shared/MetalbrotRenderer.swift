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
    
    var viewState: OriginZoom = .zero {
        didSet{
            view.setNeedsDisplay(view.bounds)
        }
    }
    
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
         device.makeBuffer(length: MemoryLayout<vector_uint2>.stride),
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
        
        vertexDescriptor.attributes[2].format = .int2
        vertexDescriptor.attributes[2].offset = 0
        vertexDescriptor.attributes[2].bufferIndex = 2
        vertexDescriptor.layouts[2].stride = MemoryLayout<vector_int2>.stride
        
        vertexDescriptor.attributes[3].format = .int2
        vertexDescriptor.attributes[3].offset = 0
        vertexDescriptor.attributes[3].bufferIndex = 3
        vertexDescriptor.layouts[3].stride = MemoryLayout<vector_int2>.stride
        
        
        descriptor.vertexDescriptor = vertexDescriptor
        
        view.enableSetNeedsDisplay = true
        view.isPaused = true
        
        pipelineState = try! device.makeRenderPipelineState(descriptor: descriptor)
        
        super.init()
        viewState = OriginZoom(frame: self.view.bounds)
        view.delegate = self

    }
    
    func render(view: MTKView, originZoom: OriginZoom){
        
        guard let descriptor = view.currentRenderPassDescriptor,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            fatalError()
        }
        
        /// \param maxX the the width of the full mandelbrot set image
        /// \param maxY the height of the full mandelbrot set image
        /// \param originX the origin horizontal pixel of the sub rect of mandelbrot set we are rendering
        /// \param originY the origin vertical pixel of the sub rect of mandelbrot set we are rendering
        /// \param dimensionX the width of the drawing region of mandelbrot set
        /// \param dimensionY the height of the drawing region of mandelbrot set
    //    int dimensionXMax = originX + dimensionX;
    //    int dimensionYMax = originY + dimensionY;
    //
    //    for (int row = originY; row < dimensionYMax; row++) {
    //        for (int col = originX; col < dimensionXMax; col++) {
        
    // INSIDE SHADER CODE
    //            double c_re = (col - maxX / 2.0) * 4.0 / maxX;
    //            double c_im = (row - maxY / 2.0) * 4.0 / maxX;
        
        let origin: vector_int2 = originZoom.getVector(.origin)
        let zoom: vector_int2 = originZoom.getVector(.zoom)
        let (viewportBuffer, originBuffer, zoomBuffer) = getBuffers
        
        print("will draw from origin \(origin)\n size:\(zoom)")
        
        
        
        let size = view.drawableSize
        let viewportSize: vector_uint2 = vector_uint2(x: UInt32(size.width), y: UInt32(size.height))
        let sizePtr = viewportBuffer?.contents()
        sizePtr?.storeBytes(of: viewportSize, as: vector_uint2.self)
        
        let originPtr = originBuffer?.contents()
        originPtr?.storeBytes(of: origin, as: vector_int2.self)

        let zoomPtr = zoomBuffer?.contents()
        zoomPtr?.storeBytes(of: zoom, as: vector_int2.self)
        
        renderEncoder.setRenderPipelineState(pipelineState)
        
        //begin actual drawing code
        
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(viewportBuffer, offset:0, index: 1)
        renderEncoder.setVertexBuffer(originBuffer, offset: 0, index: 2)
        renderEncoder.setVertexBuffer(zoomBuffer, offset: 0, index: 3)
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
    
        //END actual draw code
        
        if let drawable = view.currentDrawable {
            
            renderEncoder.endEncoding()
            commandBuffer.present(drawable)
            commandBuffer.commit()
            commandBuffer.waitUntilScheduled()
            commandBuffer.waitUntilCompleted()
            
        }
        
    }
    
}

struct OriginZoom {
    
    var frame: CGRect
    
    enum Value{
        case origin
        case zoom
    }
    
    func getVector(_ value:Value) -> vector_int2 {
        
        switch value{
        case .origin:
            return vector_int2(x: Int32(frame.origin.x), y: Int32(frame.origin.y))
        case .zoom:
            return vector_int2(x: Int32(frame.size.width), y: Int32(frame.size.height))
        }
        
    }
    
    mutating func setOrigin(_ newOrigin: CGPoint){
        print("got new origin \(newOrigin)")
        frame = CGRect(origin: newOrigin, size: frame.size)
        print("frame now \(frame)")
        
    }
    
    
    mutating func setZoom(_ newZoom: CGRect){
        print("got new frame \(newZoom)")
        frame = newZoom
        print("frame now \(frame)")
    }
    
    static var zero: OriginZoom = OriginZoom(frame: .zero)
    
}

//MARK: Metal Kit
extension MetalbrotRenderer: MTKViewDelegate {
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        view.setNeedsDisplay(.init(origin: .zero, size: size))
    }
    
    func updateZoom(_ newSize: CGRect){
        viewState.setZoom(newSize)
    }
    
    func updatePan(_ origin: CGPoint){
        viewState.setOrigin(origin)
    }
    
    func draw(in view: MTKView) {
        render(view: view, originZoom: self.viewState)
    }
    
}
