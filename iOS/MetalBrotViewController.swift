//
//  MetalBrotView.swift
//  Metalbrot
//
//  Created by Joss Manger on 6/11/22.
//

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
            let gestureTranslation = recognizer.translation(in: metalView)
            let updateTranslation = CGPoint(x: -gestureTranslation.x, y: -gestureTranslation.y)
            viewModel?.updateCenter(updateTranslation)
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
            let scrollzoom = 1 - recognizer.scale// / 2
            (viewModel as! MetalbrotRendererViewModel).setZoom(scrollzoom)
        case .cancelled, .failed:
            print("some error, pinch gesture ended with code \(recognizer.state)")
        default:
            print("unhandled pinch gesture case \(recognizer.state)")
        }

    }
    
}
