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
    
    let viewRect: MyView = {
        let view = MyView(frame: NSRect(origin: .zero, size: CGSize(width: 30, height: 30)))
        
        return view
    }()
    
    var startSize: CGRect = .zero
    var zoomSize: CGRect! = .zero
    
    var totalXScale: CGFloat = 100
    var totalYScale:  CGFloat = 100
    
    var translation: NSPoint!
    var gesture: NSPanGestureRecognizer!
    
    init(){
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func loadView() {
        let device = MTLCreateSystemDefaultDevice()!
        metalView = MTKView(frame: .zero, device: device)
        self.view = metalView
        metalView.autoresizingMask = [.height,.width]
        renderer = MetalbrotRenderer(device: device, view: metalView)
        renderer?.delegate = self
        viewRect.frame = self.view.bounds
        viewRect.autoresizingMask = [.height,.width]
        self.view.addSubview(viewRect)
    }
    
    override func viewDidLoad() {
        gesture = NSPanGestureRecognizer(target: self, action: nil)
        print("hello world")

    }
    
//    override func viewDidLayout() {
//        print("view center: \(self.view.bounds.center) \(self.view.frame.center)")
//        translation = self.view.frame.center
//    }
    
    override func mouseDragged(with event: NSEvent) {
        
        let translation = CGPoint(x: translation.x - event.deltaX, y: translation.y - event.deltaY)
        viewRect.layer?.position = translation
        self.translation = translation
        renderer?.updatePan(translation)
        
    }
    
    override func scrollWheel(with event: NSEvent) {
        
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

extension ViewController: MetalViewUpdateDelegate {
    
    func translationDidUpdate(point: CGPoint) {
        print("got updated translation \(point)")
        translation = point
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

