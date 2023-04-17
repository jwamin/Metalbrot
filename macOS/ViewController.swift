//
//  ViewController.swift
//  Metalbrot (macOS)
//
//  Created by Joss Manger on 6/15/22.
//

import Cocoa
import SwiftUI
import MetalKit

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
        
    }
    
    var start: NSPoint!
    var translation: NSPoint!
    var end: NSPoint!
    
    override func mouseDown(with event: NSEvent) {
        metalView.setNeedsDisplay(.init(origin: .zero, size: metalView.drawableSize))
        start = event.locationInWindow
    }
    
    override func mouseDragged(with event: NSEvent) {
        //let location = gesture?.location(in: self.view)
        translation = event.locationInWindow
        print("moved at \(translation)")
        let translation = CGSize(width: start.x - translation.x, height: start.y - translation.y)
        
        renderer?.updateZoomArea(translation)
        
    }
    
    override func mouseUp(with event: NSEvent) {
        
        //let location = gesture?.location(in: self.view)
        end = event.locationInWindow
        print("ended at \(end)")
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
