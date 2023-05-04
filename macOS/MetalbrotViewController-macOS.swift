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
    
    let viewRect: MyView = {
        let view = MyView(frame: NSRect(origin: .zero, size: CGSize(width: 30, height: 30)))
        
        return view
    }()
    
    var totalYScale:  CGFloat = 100
    
    var translation: NSPoint!
    var gesture: NSPanGestureRecognizer!
    
    override init(){
        super.init()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func loadView() {
        super.loadView()
        metalView.autoresizingMask = [.height,.width]
        renderer?.delegate = self
        viewRect.frame = self.view.bounds
        viewRect.autoresizingMask = [.height,.width]
        self.view.addSubview(viewRect)
    }
    
    override func viewDidLoad() {
        gesture = NSPanGestureRecognizer(target: self, action: nil)
        print("hello world")

    }
    
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
        renderer?.updateZoom(viewRect.layer!.frame, updateDelegate: false)
    }
    
}




