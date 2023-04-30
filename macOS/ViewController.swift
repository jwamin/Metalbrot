//
//  ViewController.swift
//  Metalbrot (macOS)
//
//  Created by Joss Manger on 6/15/22.
//

import Cocoa
import SwiftUI
import MetalKit

class MyView: NSView {
    override func draw(_ dirtyRect: NSRect) {
//        print("frame",self.frame)
//        print("drect",dirtyRect)
//        NSColor.red.setFill()
//        dirtyRect.fill()
    }
}

class ViewController: NSViewController {

    var metalView: MTKView!
    var renderer: MetalbrotRenderer?
    
    init(){
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func loadView() {
        view = NSView(frame: NSRect(origin: .zero, size: CGSize(width: 640, height: 480)))
    }
    
    var gesture: NSPanGestureRecognizer!
    
    override func viewDidLoad() {
        let device = MTLCreateSystemDefaultDevice()!
        metalView = MTKView(frame: self.view.bounds, device: device)
        self.view.addSubview(metalView)
        metalView.autoresizingMask = [.height,.width]
        renderer = MetalbrotRenderer(device: device, view: metalView)
        gesture = NSPanGestureRecognizer(target: self, action: nil)
        print("hello world")
        viewRect.frame = self.view.bounds
        viewRect.autoresizingMask = [.height,.width]
        self.view.addSubview(viewRect)
    }

    var translation: NSPoint!
    
    override func viewDidLayout() {
        renderer?.updateZoom(self.view.bounds)
        translation = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2)
    }
    
    override func mouseDragged(with event: NSEvent) {
        //let location = gesture?.location(in: self.view)
        
        let translation = CGPoint(x: translation.x - event.deltaX, y: translation.y - event.deltaY)
        viewRect.layer?.position = translation
        self.translation = translation
        renderer?.updatePan(translation)
        
    }
    
    let viewRect: MyView = MyView(frame: NSRect(origin: .zero, size: CGSize(width: 30, height: 30)))
    
    var startSize: CGRect = .zero
    var zoomSize: CGRect! = .zero
    
    var totalXScale: CGFloat = 100
    var totalYScale:  CGFloat = 100
    
    override func scrollWheel(with event: NSEvent) {
        
        totalXScale += event.scrollingDeltaX
        totalYScale += event.scrollingDeltaY
        let yScale: CGFloat = totalYScale / 100
        viewRect.layer?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        viewRect.layer?.position = translation
        viewRect.layer?.setAffineTransform(.init(scaleX: yScale, y: yScale))
        viewRect.setNeedsDisplay(viewRect.bounds)
        translation = viewRect.layer?.position
        renderer?.viewState.setZoom(viewRect.layer!.frame)
    }
    

    
}

struct SwiftUIMetalKitView: NSViewControllerRepresentable {

    typealias NSViewControllerType = ViewController
    typealias NSViewType = NSView
    
    func makeNSViewController(context: Context) -> ViewController {
        ViewController()
    }
    
    func updateNSViewController(_ nsViewController: ViewController, context: Context) {
        print("view updated")
    }
    
    func makeCoordinator() -> Bool? {
        true
    }
    
}
