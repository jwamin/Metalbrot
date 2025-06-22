//
//  BaseBrotViewController.swift
//  Metalbrot
//
//  Created by Joss Manger on 5/4/23.
//

#if os(macOS)
import Cocoa
typealias ViewController = NSViewController
fileprivate let basicPinning: NSView.AutoresizingMask = [.width, .height]
#elseif os(iOS) || targetEnvironment(macCatalyst) || os(tvOS)
import UIKit
typealias ViewController = UIViewController
fileprivate let basicPinning: UIView.AutoresizingMask = [.flexibleWidth, .flexibleHeight]
#endif

import MetalKit
import SwiftUI

class MetalbrotBaseViewController: ViewController {
    
    var metalView: MTKView {
        self.view as! MTKView
    }
    
    var renderer: MetalbrotRenderer?
    var viewModel: MetalbrotViewModelInterface?
    
    override func loadView() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("No Metal Device")
        }
        
        let metalView = MTKView(frame: .zero, device: device)
        self.view = metalView
        metalView.autoresizingMask = basicPinning
        
        // Setup tap/click gesture
        #if os(macOS)
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleTap))
        metalView.addGestureRecognizer(clickGesture)
        #else
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        metalView.addGestureRecognizer(tapGesture)
        #endif
        
        renderer = MetalbrotRenderer(view: metalView)
    }
    
    override func viewDidLoad() {
        viewModel = MetalbrotRendererViewModel()
        renderer?.viewModel = viewModel
    }
    
    @objc private func handleTap() {
        viewModel?.cycleColorScheme()
    }
}
