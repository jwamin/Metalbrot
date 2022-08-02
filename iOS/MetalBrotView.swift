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
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        renderer?.render(view: metalView)
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
