//
//  MetalbrotRenderer.swift
//  Metalbrot
//
//  Created by Joss Manger on 11/24/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import MetalKit

protocol MetalViewUpdateDelegate {
    func translationDidUpdate(point: CGPoint)
}

class MetalbrotRenderer: NSObject {
    
    let device:MTLDevice
    unowned let view:MTKView
    let library:MTLLibrary
    let descriptor:MTLRenderPipelineDescriptor
    let pipelineState:MTLRenderPipelineState
    let commandQueue:MTLCommandQueue
    
    var delegate: MetalViewUpdateDelegate?
    
    private var viewState: OriginZoom = .zero {
        didSet{
            view.setNeedsDisplay(view.bounds)
        }
    }
    
    //use semaphore to synchronize CPU and GPU work?
    private var manuallySynchronize: Bool = false
    let semaphore = DispatchSemaphore(value: 0)
    
    typealias metalbuffers = (vertexBuffer: MTLBuffer?, viewportBuffer: MTLBuffer?, originBuffer: MTLBuffer?, zoomBuffer: MTLBuffer?)
    
    lazy var getBuffers: metalbuffers = {
        (device.makeBuffer(bytes: MetalbrotConstants.data.vertices, length: MemoryLayout<vector_float2>.size * MetalbrotConstants.data.vertices.count),
         device.makeBuffer(length: MemoryLayout<vector_uint2>.stride),
         device.makeBuffer(length: MemoryLayout<vector_uint2>.stride),
         device.makeBuffer(length: MemoryLayout<vector_uint2>.stride))
    }()
    
    convenience init(view: MTKView) {
        guard let device = view.device else {
            fatalError("tried to use convenience initializer without MTLDevice on MTKView")
        }
        self.init(device: device, view: view)
    }
    
    init(device: MTLDevice,view: MTKView){
        
        self.device = device
        self.library = device.makeDefaultLibrary()!
        self.commandQueue = device.makeCommandQueue()!
        
        self.view = view
        //view.preferredFramesPerSecond = 30
        if #available(macOS 13.0, iOS 16.0, *) {
            (view.layer as! CAMetalLayer).developerHUDProperties = [
                "mode":"default"
            ]
        }
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
        vertexDescriptor.layouts[0].stride = MemoryLayout<vector_float2>.stride
        
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
        let (vertexBuffer, viewportBuffer, originBuffer, zoomBuffer) = getBuffers

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
            if manuallySynchronize {
                commandBuffer.addCompletedHandler {[weak self] buffer in
                    print("2 finished waiting")
                    self?.semaphore.signal()
                }
                commandBuffer.commit()
                print("1 waiting")
                semaphore.wait()
                print("3 waited")
            } else {
                commandBuffer.commit()
                commandBuffer.waitUntilScheduled()
                commandBuffer.waitUntilCompleted()
            }
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
    
    mutating func setPosition(_ newPosition: CGPoint){
        let newOrigin = CGPoint(x: newPosition.x - (frame.size.width / 2), y: newPosition.y - (frame.size.height / 2))
        frame = CGRect(origin: newOrigin, size: frame.size)
    }
    
    mutating func setZoom(_ newZoom: CGRect){
        frame = newZoom
    }
    
    static var zero: OriginZoom = OriginZoom(frame: .zero)
    
}

extension OriginZoom: CustomStringConvertible {
    var description: String{
        "\(frame)"
    }
}

//MARK: Metal Kit
extension MetalbrotRenderer: MTKViewDelegate {
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        updateZoom(.init(origin: viewState.frame.origin, size: size),updateDelegate: true)
    }
    
    func updateZoom(_ newSize: CGRect, updateDelegate: Bool = true){
        viewState.setZoom(newSize)
        if updateDelegate {
            delegate?.translationDidUpdate(point: newSize.center)
        }
    }
    
    func updatePan(_ position: CGPoint, updateDelegate: Bool = true){
        viewState.setPosition(position)
        if updateDelegate {
            delegate?.translationDidUpdate(point: position)
        }
    }
    
    func draw(in view: MTKView) {
        render(view: view, originZoom: self.viewState)
    }
    
}
