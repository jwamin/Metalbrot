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

class MetalbrotViewController: MetalbrotBaseViewController {
    
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
        viewModel?.updateCenter(CGPoint(x: event.locationInWindow.x, y: event.locationInWindow.y))
    }
    
    override func scrollWheel(with event: NSEvent) {
        
        let scrollzoom = CGFloat(event.scrollingDeltaY) / 100
        //print(scrollzoom)
        viewModel?.updateZoom(scrollzoom)
        
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




