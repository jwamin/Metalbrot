//
//  MetalBrotView.swift
//  Metalbrot
//
//  Created by Joss Manger on 6/11/22.
//

#if os(macOS)
import Cocoa
#elseif os(iOS)
import UIKit
#elseif targetEnvironment(macCatalyst)
import UIKit
#endif

import MetalKit
import SwiftUI

final class MetalBrotViewController: UIViewController, MTKViewDelegate {

    var metalView: MTKView!
    var renderer: Renderer?
    
    override func viewDidLoad() {
        let device = MTLCreateSystemDefaultDevice()!
        metalView = MTKView(frame: self.view.bounds, device: device)
        self.view.addSubview(metalView)
        metalView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        renderer = Renderer(device: device, view: metalView)
        
        print("hello world")
        metalView.delegate = self
        renderer?.render()
    }
    
    //MARK: Metal Kit
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
     print("drawable size now \(size)")
    }
    
    func draw(in view: MTKView) {
        if let renderer = renderer {
            renderer.render()
        }
    }
    
}

class Setting {
    let bool: Bool
    init(newBool: Bool = false){
        self.bool = newBool
    }
}

final class SwiftUIMetalKitView: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = MetalBrotViewController
    typealias UIViewType = UIView
    
    func makeUIViewController(context: Context) -> MetalBrotViewController {
        MetalBrotViewController()
    }
    
    func updateUIViewController(_ uiViewController: MetalBrotViewController, context: Context) {
        print("view updated")
    }

    func makeCoordinator() -> Setting {
        Setting()
    }
    

}
