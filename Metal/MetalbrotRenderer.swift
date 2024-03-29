//
//  MetalbrotRenderer.swift
//  Metalbrot
//
//  Created by Joss Manger on 11/24/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import MetalKit
import Combine

class MetalbrotRenderer: NSObject {
    
    let device: MTLDevice
    unowned let metalKitView: MTKView
    let descriptor: MTLRenderPipelineDescriptor
    private var pipelineState: MTLRenderPipelineState?
    let commandQueue: MTLCommandQueue
    
    weak var viewModel: MetalbrotViewModelInterface? {
        didSet{
            setupViewModel()
        }
    }
    
    ///Combine
    private var storage: Set<AnyCancellable> = Set<AnyCancellable>()
    
    //Timing
    //use semaphore to synchronize CPU and GPU work?
    private var manuallySynchronize: Bool = false
    let semaphore = DispatchSemaphore(value: 0)
    
    
    ///Metal Variables
    private typealias metalbuffers = (vertexBuffer: MTLBuffer?, viewportBuffer: MTLBuffer?, originBuffer: MTLBuffer?, zoomBuffer: MTLBuffer?)
    
    private lazy var getBuffers: metalbuffers = {
        (device.makeBuffer(bytes: MetalbrotConstants.data.vertices, length: MemoryLayout<vector_float2>.size * MetalbrotConstants.data.vertices.count),
         device.makeBuffer(length: MemoryLayout<vector_uint2>.stride),
         device.makeBuffer(length: MemoryLayout<vector_int2>.stride),
         device.makeBuffer(length: MemoryLayout<vector_int2>.stride))
    }()
    

    init(device: MTLDevice,view: MTKView){
        
        self.metalKitView = view
        self.device = device
        self.commandQueue = device.makeCommandQueue()!
        self.descriptor = MTLRenderPipelineDescriptor()

        super.init()
    
        configureView()
        setupRenderPipeline()
    
        //hooking up delegate causes view to begin rendering on resize / vm update
        view.delegate = self
        
    }
    
    convenience init(view: MTKView) {
        guard let device = view.device else {
            fatalError("tried to use convenience initializer without MTLDevice on MTKView")
        }
        self.init(device: device, view: view)
    }
    
    
    private func setupViewModel(){
        guard let viewModel = viewModel else {
            fatalError("cannot setup view model bindings with viewmodel nil")
        }
        
        viewModel.updateCenter(metalKitView.bounds.center)
        
        Publishers.CombineLatest(viewModel.centerPublisher, viewModel.zoomLevelPublisher)
            .map { _ in
                Void()
            }
            .sink(receiveValue: { [weak self] _ in
                self?.renderAll()
            }).store(in: &storage)
        
        //Set view model bindings
        
    }
    
    private func configureView(){
        metalKitView.clearColor = Color.systemBlue.metalClearColor()
        if #available(macOS 13.0, iOS 16.0, *) {
            (metalKitView.layer as! CAMetalLayer).developerHUDProperties = [
                "mode":"default"
            ]
        }
    }
    
    private func setupRenderPipeline(){

        let library = device.makeDefaultLibrary()!
        let vertexFunction = library.makeFunction(name: "brot_vertex_main")
        let fragmentFunction = library.makeFunction(name: "brot_fragment_main")
        
        if #available(macOS 13.0, iOS 16.0, *) {
            (metalKitView.layer as! CAMetalLayer).developerHUDProperties = [
                "mode":"default"
            ]
        }
        
        descriptor.vertexFunction = vertexFunction
        descriptor.fragmentFunction = fragmentFunction
        descriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
        
        //Vertex
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float2
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.layouts[0].stride = MemoryLayout<vector_float2>.stride
        
        //Viewport
        vertexDescriptor.attributes[1].format = .uint2
        vertexDescriptor.attributes[1].offset = 0
        vertexDescriptor.attributes[1].bufferIndex = 1
        vertexDescriptor.layouts[1].stride = MemoryLayout<vector_uint2>.stride
        
        //Origin
        vertexDescriptor.attributes[2].format = .int2
        vertexDescriptor.attributes[2].offset = 0
        vertexDescriptor.attributes[2].bufferIndex = 2
        vertexDescriptor.layouts[2].stride = MemoryLayout<vector_int2>.stride
        
        //Zoom
        vertexDescriptor.attributes[3].format = .float2
        vertexDescriptor.attributes[3].offset = 0
        vertexDescriptor.attributes[3].bufferIndex = 3
        vertexDescriptor.layouts[3].stride = MemoryLayout<vector_float2>.stride
        
        descriptor.vertexDescriptor = vertexDescriptor
        
        metalKitView.enableSetNeedsDisplay = true
        metalKitView.isPaused = true
        
        pipelineState = try! device.makeRenderPipelineState(descriptor: descriptor)
    }
    
    func render(view: MTKView){
        
        guard let descriptor = view.currentRenderPassDescriptor,
              let pipelineState = pipelineState,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            fatalError("Unable to create render encoder")
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
        
        
        let (vertexBuffer, viewportBuffer, originBuffer, zoomBuffer) = getBuffers
        let drawableSize: vector_uint2 = view.drawableSize.vector_uint2_32
        
        let (origin, zoomSize) = viewModel!.getAdjustedRect(viewSize: drawableSize)
        
        //print(drawableSize,origin,zoomSize)
        let sizePtr = viewportBuffer?.contents()
        sizePtr?.storeBytes(of: drawableSize, as: vector_uint2.self)
        
        let originPtr = originBuffer?.contents()
        originPtr?.storeBytes(of: origin, as: vector_int2.self)

        let zoomPtr = zoomBuffer?.contents()
        zoomPtr?.storeBytes(of: zoomSize, as: vector_float2.self)
        
        renderEncoder.setRenderPipelineState(pipelineState)
        
        //begin actual drawing code
        for (bufferIndex,buffer) in [vertexBuffer,viewportBuffer,originBuffer,zoomBuffer].enumerated(){
            renderEncoder.setVertexBuffer(buffer, offset: 0, index: bufferIndex)
        }
        
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

//MARK: Metal Kit
extension MetalbrotRenderer: MTKViewDelegate {
    
    func renderAll(){
        metalKitView.setNeedsDisplay(metalKitView.bounds)
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        view.setNeedsDisplay(view.bounds)
    }
    
    func draw(in view: MTKView) {
        render(view: view)
    }
    
}
