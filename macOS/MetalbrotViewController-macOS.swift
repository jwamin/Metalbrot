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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("hello world - macOS")

    }
    
    override func mouseDragged(with event: NSEvent) {

        
    }
    
    override func scrollWheel(with event: NSEvent) {
        
        let scrollzoom = max(Int(event.scrollingDeltaY), 1)
        print(scrollzoom)
        viewModel?.updateZoom(scrollzoom)
        
    }
    
}




