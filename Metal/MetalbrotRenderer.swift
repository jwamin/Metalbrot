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
    private typealias metalbuffers = (vertexBuffer: MTLBuffer?, viewportBuffer: MTLBuffer?, originBuffer: MTLBuffer?, zoomBuffer: MTLBuffer?, colorBuffer: MTLBuffer?)
    
    private var buffers: [MTLBuffer?] = []
    
    private lazy var getBuffers: metalbuffers = {
        (device.makeBuffer(bytes: MetalbrotConstants.data.vertices, length: MemoryLayout<vector_float2>.size * MetalbrotConstants.data.vertices.count),
         device.makeBuffer(length: MemoryLayout<vector_uint2>.stride),
         device.makeBuffer(length: MemoryLayout<vector_int2>.stride),
         device.makeBuffer(length: MemoryLayout<vector_int2>.stride),
         device.makeBuffer(length: MemoryLayout<vector_float4>.stride)
        )
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
        
        // Clear existing subscriptions before setting up new ones
        storage.removeAll()
        
        //Basic Listener to look for _any_ changes on view model @Published interface
        Publishers.CombineLatest3(viewModel.centerPublisher, viewModel.zoomLevelPublisher, viewModel.selectedColorSchemePublisher)
            .map { _ in
                Void()
            }
            .sink(receiveValue: { [weak self] _ in
                self?.renderAll()
            }).store(in: &storage)
        
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
        
        descriptor.vertexFunction = vertexFunction
        descriptor.fragmentFunction = fragmentFunction
        descriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
        
        let vertexDescriptor = MTLVertexDescriptor()
        
        let attributes: [(format: MTLVertexFormat, bufferIndex: Int, stride: Int)] = [
            (.float2, 0, MemoryLayout<vector_float2>.stride),   // Vertex
            (.uint2, 1, MemoryLayout<vector_uint2>.stride),     // Viewport
            (.int2, 2, MemoryLayout<vector_int2>.stride),       // Origin
            (.float2, 3, MemoryLayout<vector_float2>.stride),   // Zoom
            (.float4, 4, MemoryLayout<vector_float4>.stride)    // Color
        ]
        
        for (index, (format, bufferIndex, stride)) in attributes.enumerated() {
            vertexDescriptor.attributes[index].format = format
            vertexDescriptor.attributes[index].offset = 0
            vertexDescriptor.attributes[index].bufferIndex = bufferIndex
            vertexDescriptor.layouts[bufferIndex].stride = stride
        }
        
        descriptor.vertexDescriptor = vertexDescriptor
        
        metalKitView.enableSetNeedsDisplay = true
        metalKitView.isPaused = true
        
        pipelineState = try! device.makeRenderPipelineState(descriptor: descriptor)
    }
    
    
    /// Main Render Function
    /// - Parameter view: render surface
    func render(view: MTKView){
        
        guard let descriptor = view.currentRenderPassDescriptor,
              let pipelineState = pipelineState,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor),
              let viewModel = viewModel else {
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
        
        
        let (vertexBuffer, viewportBuffer, originBuffer, zoomBuffer, colorBuffer) = getBuffers
        
        if buffers.isEmpty {
            self.buffers = [vertexBuffer, viewportBuffer, originBuffer, zoomBuffer, colorBuffer]
        }
        
        let drawableSize = view.drawableSize.vector_uint2_32
        let (origin, zoomSize) = viewModel.getAdjustedRect(viewSize: drawableSize)
        
        // Update buffer contents
        viewportBuffer?.contents().storeBytes(of: drawableSize, as: vector_uint2.self)
        originBuffer?.contents().storeBytes(of: origin, as: vector_int2.self)
        zoomBuffer?.contents().storeBytes(of: zoomSize, as: vector_float2.self)
        colorBuffer?.contents().storeBytes(of: #colorLiteral(red: 0.3036130369, green: 0.1568089426, blue: 0.5214661956, alpha: 1).float4(), as: vector_float4.self)
        
        // Create and set color scheme buffer
        var colorScheme = viewModel.selectedColorScheme
        let colorSchemeBuffer = device.makeBuffer(bytes: &colorScheme, length: MemoryLayout<UInt32>.stride)
        renderEncoder.setVertexBuffer(colorSchemeBuffer, offset: 0, index: 5)
        
        renderEncoder.setRenderPipelineState(pipelineState)
        // Set vertex buffers and draw
        for (index, buffer) in buffers.enumerated() {
            renderEncoder.setVertexBuffer(buffer, offset: 0, index: index)
        }
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        
        // Present and commit
        if let drawable = view.currentDrawable {
            renderEncoder.endEncoding()
            commandBuffer.present(drawable)
            
            if manuallySynchronize {
                commandBuffer.addCompletedHandler { [weak self] _ in
                    self?.semaphore.signal()
                }
                commandBuffer.commit()
                semaphore.wait()
            } else {
                commandBuffer.commit()
                commandBuffer.waitUntilScheduled()
                commandBuffer.waitUntilCompleted()
            }
        }
        
    }
    
}


//MARK: Metal Kit View Delegate
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
