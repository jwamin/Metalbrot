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
    var panRecognizer: UIPanGestureRecognizer?
    var pinchRecognizer: UIPinchGestureRecognizer?
    var currentPosition: CGPoint = .zero
    var endPosition: CGPoint = .zero
    private var firstRun: Bool = true
    var guideLayer: CALayer!
    override func viewDidLoad() {
        let device = MTLCreateSystemDefaultDevice()!
        metalView = MTKView(frame: self.view.bounds, device: device)
        self.view.addSubview(metalView)
        metalView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        metalView.presentsWithTransaction = true
        
        renderer = MetalbrotRenderer(device: device, view: metalView)
        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:)))
        panRecognizer?.maximumNumberOfTouches = 1
        metalView.addGestureRecognizer(panRecognizer!)
        pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(self.handlePinch(_:)))
        metalView.addGestureRecognizer(pinchRecognizer!)
        print("hello world")
        guideLayer = CALayer()
//        guideLayer.backgroundColor = UIColor.magenta.cgColor
//        guideLayer.opacity = 0.2
        guideLayer.frame = self.view.bounds
        guideLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5) //TODO: centerAnchor
        self.view.layer.addSublayer(guideLayer)
        
    }
    
    override func viewDidLayoutSubviews() {
        if firstRun{
            renderer?.updateZoom(self.view.bounds)
            firstRun = false
        }
    }
    
    @objc
    func handlePan(_ recognizer: UIPanGestureRecognizer){
        let gestureTranslation = recognizer.translation(in: metalView)
        let gesturePosition = recognizer.location(in: metalView)
        
        let multiplyer: CGFloat = 2
        switch(recognizer.state){
        case .began:
            print("started at \(gesturePosition)")
        case .changed:
            
            let dX = gestureTranslation.x * multiplyer
            let dY = gestureTranslation.y * multiplyer
            
            
            let translation = CGPoint(x: currentPosition.x - dX, y: currentPosition.y - dY)
            self.renderer?.updatePan(translation)
            endPosition = translation
        case.ended, .cancelled, .failed:
            currentPosition = endPosition
            //let velocity = recognizer.velocity(in: metalView)
            //            //animate back to center
            //            // 1
            //            let velocity = recognizer.velocity(in: view)
            //            let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
            //            let slideMultiplier = magnitude / 200
            //
            //            // 2
            //            let slideFactor = 0.1 * slideMultiplier
            //            // 3
            //            var finalPoint = CGPoint(
            //              x: metalView.center.x + (velocity.x * slideFactor),
            //              y: metalView.center.y + (velocity.y * slideFactor)
            //            )
            //
            //            // 4
            //            finalPoint.x = min(max(finalPoint.x, 0), view.bounds.width)
            //            finalPoint.y = min(max(finalPoint.y, 0), view.bounds.height)
            //
            //            // 5
            //            print("ended at \(gesturePosition)")
            //
            //            let animation = CABasicAnimation(keyPath: "customSize")
            //            animation.fromValue = currentPosition
            //            animation.toValue = CGPoint.zero
            //            animation.duration = 2
            //            animation.isRemovedOnCompletion = true
            //            metalView.layer
            //            UIView.animate(
            //              //withDuration: Double(slideFactor * 2),
            //                withDuration: 2,
            //              delay: 0,
            //              // 6
            //              options: .curveEaseOut,
            //              animations: { [weak self] in
            //                  self?.renderer?.customSize = .zero
            //            })
            
//            UIView.animate(
//                //withDuration: Double(slideFactor * 2),
//                withDuration: 2,
//                delay: 0,
//                // 6
//                options: .curveEaseOut,
//                animations: { [weak self] in
//                    CATransaction.begin()
//                    CATransaction.setAnimationDuration(2)
//
//                    CATransaction.setCompletionBlock({ [weak self] in
//                        self?.currentPosition = .zero
//                        print("done?")
//                    })
//                    //CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut))
//
//                    CATransaction.commit()
//                })
        default:
            print("do nothing with gesture state \(recognizer.state)")
        }
    }
    
    @objc
    func handlePinch(_ recognizer: UIPinchGestureRecognizer){
        
        switch(recognizer.state){
        case .changed:
            let scale = recognizer.scale
            print(scale)
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            
            guideLayer.position = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
            guideLayer.setAffineTransform(.init(scaleX: -scale, y: -scale))
            print("glfram",guideLayer.frame)
            self.view.layer.layoutSublayers()
            CATransaction.commit()
            renderer?.updateZoom(guideLayer.frame)
        default:
            print("do nothing")
        }
        
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