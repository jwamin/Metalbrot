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
    
    init(){
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("No Metal Device")
        }
        
        let metalView = MTKView(frame: .zero, device: device)
        self.view = metalView
        metalView.autoresizingMask = basicPinning
        
        renderer = MetalbrotRenderer(view: metalView)
    }
    
    override func viewDidLoad() {
        viewModel = MetalbrotRendererViewModel()
        renderer?.viewModel = viewModel
    }
    
}
