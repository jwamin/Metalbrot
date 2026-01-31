//
//  ViewController.swift
//  Metalbrot (macOS)
//
//  Created by Joss Manger on 6/15/22.
//

#if os(macOS)
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

class MetalbrotViewController: MetalbrotBaseViewController {
    
    private var lastScrollTimestamp: TimeInterval?
    
    override func loadView() {
        super.loadView()

    }
    
    override var acceptsFirstResponder: Bool {
        true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("hello world - macOS \(acceptsFirstResponder)")
        becomeFirstResponder()
        
    }
    
    
    override func mouseDragged(with event: NSEvent) {
        //TODO: Move to viewmodel
        viewModel?.stopZoomInertia()
        let current = viewModel?.center ?? .zero
        let zoom = max(viewModel?.zoomLevel ?? 1, 0.0001)
        let updateTranslation = CGPoint(x: -event.deltaX * zoom, y: -event.deltaY * zoom)
        viewModel?.updateCenter(CGPoint(x: current.x + updateTranslation.x, y: current.y + updateTranslation.y))
    }
    
    override func scrollWheel(with event: NSEvent) {
        //TODO: Move to viewmodel
        if event.phase == .began {
            viewModel?.stopZoomInertia()
            lastScrollTimestamp = event.timestamp
        }
        let locationInView = metalView.convert(event.locationInWindow, from: nil)
        let focus = CGPoint(x: locationInView.x, y: metalView.bounds.height - locationInView.y)
        viewModel?.applyZoom(delta: CGFloat(event.scrollingDeltaY), focus: focus, viewSize: metalView.bounds.size)
        
        if event.momentumPhase == .none && event.phase == .ended {
            if let lastTimestamp = lastScrollTimestamp {
                let dt = max(event.timestamp - lastTimestamp, 0.001)
                let velocity = CGFloat(event.scrollingDeltaY) / dt
                viewModel?.startZoomInertia(deltaVelocity: velocity, focus: focus, viewSize: metalView.bounds.size)
            }
            lastScrollTimestamp = nil
        } else {
            lastScrollTimestamp = event.timestamp
        }
    }
    
    override func interpretKeyEvents(_ eventArray: [NSEvent]) {
        print(eventArray)
    }
    
    override func keyDown(with event: NSEvent) {
        super.keyDown(with: event)
        print(event.keyCode)
    }
    
    override func keyUp(with event: NSEvent) {
        super.keyUp(with: event)
        print(event.keyCode)
        //if event.keyCode == .
        
    }
    
}

#endif
