//
//  MetalBrotView.swift
//  Metalbrot
//
//  Created by Joss Manger on 6/11/22.
//

#if os(iOS)
import UIKit
import MetalKit
import SwiftUI

final class MetalbrotViewController: MetalbrotBaseViewController {
    
    var panRecognizer: UIPanGestureRecognizer?
    var pinchRecognizer: UIPinchGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("hello world - iOS")
        setupGestures()
    }


    func setupGestures(){
        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:)))
        panRecognizer?.maximumNumberOfTouches = 1
        view.addGestureRecognizer(panRecognizer!)
        
        pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(self.handlePinch(_:)))
        view.addGestureRecognizer(pinchRecognizer!)
    }
    
    @objc
    func handlePan(_ recognizer: UIPanGestureRecognizer){
        switch(recognizer.state){
        case .began, .changed, .ended:
            //TODO: Move to viewmodel
            viewModel?.stopZoomInertia()
            let gestureTranslation = recognizer.translation(in: metalView)
            let current = viewModel?.center ?? .zero
            let zoom = max(viewModel?.zoomLevel ?? 1, 0.0001)
            let updateTranslation = CGPoint(x: -gestureTranslation.x / zoom, y: -gestureTranslation.y / zoom)
            viewModel?.updateCenter(CGPoint(x: current.x + updateTranslation.x, y: current.y + updateTranslation.y))
            recognizer.setTranslation(.zero, in: metalView)
        case .cancelled, .failed:
            print("some error, pan gesture ended with code \(recognizer.state)")
        default:
            print("unhandled pan gesture case \(recognizer.state)")
        }
    }

    @objc
    func handlePinch(_ recognizer: UIPinchGestureRecognizer){
        switch(recognizer.state){
        case .began,.changed, .ended:
            viewModel?.stopZoomInertia()
            viewModel?.applyZoom(scaleFactor: 1.0 / max(recognizer.scale, 0.0001), focus: recognizer.location(in: metalView), viewSize: metalView.bounds.size)
            recognizer.scale = 1
            if recognizer.state == .ended {
                viewModel?.startZoomInertia(scaleVelocity: recognizer.velocity, focus: recognizer.location(in: metalView), viewSize: metalView.bounds.size)
            }
        case .cancelled, .failed:
            print("some error, pinch gesture ended with code \(recognizer.state)")
        default:
            print("unhandled pinch gesture case \(recognizer.state)")
        }

    }
    
}

#endif
