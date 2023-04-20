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

final class MetalBrotViewController: UIViewController {

    var metalView: MTKView!
    var renderer: MetalbrotRenderer?
    
    override func viewDidLoad() {
        let device = MTLCreateSystemDefaultDevice()!
        metalView = MTKView(frame: self.view.bounds, device: device)
        self.view.addSubview(metalView)
        metalView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        renderer = MetalbrotRenderer(device: device, view: metalView)
        
        print("hello world")
        
    }
    
    var translation: CGPoint = .zero
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        metalView.setNeedsDisplay(.init(origin: .zero, size: metalView.drawableSize))
    
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else {
            return
        }
        
        let position = touch.location(in: metalView)
        let previous = touch.previousLocation(in: metalView)
        
        let dX = position.x - previous.x
        let dY = position.y - previous.y
        
        let translation = CGPoint(x: translation.x - dX, y: translation.y - dY)
        
        print("moved at \(translation)")
        self.translation = translation
        renderer?.updateZoomArea(translation)
    }
    
}

class Setting {
    let bool: Bool
    init(newBool: Bool = false){
        self.bool = newBool
    }
}

struct SwiftUIMetalKitView: UIViewControllerRepresentable {
    
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
