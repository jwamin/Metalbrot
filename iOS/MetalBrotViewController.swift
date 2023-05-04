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
    
    var metalView: MTKView {
        self.view as! MTKView
    }
    var guideLayer: CALayer!
    var translation: CGPoint!
    
    var renderer: MetalbrotRenderer?
    var panRecognizer: UIPanGestureRecognizer?
    var pinchRecognizer: UIPinchGestureRecognizer?
    
    private var firstRun: Bool = true
    
    
    override func loadView() {
        
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("No Metal Device")
        }
        
        let metalView = MTKView(frame: .zero, device: device)
        self.view = metalView
        metalView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
    }
    
    override func viewDidLoad() {

        renderer = MetalbrotRenderer(view: metalView)
        renderer?.delegate = self
        
        print("hello world")
    
        setupGuideLayer()
        setupGestures()
        
    }
    
    override func viewDidLayoutSubviews() {
        if firstRun{
            guideLayer.frame = self.view.frame
            firstRun = false
        }
    }
    
    func setupGuideLayer(){
        guideLayer = CALayer()
        guideLayer.frame = self.view.bounds
        
        //DEBUGGING
//        guideLayer.backgroundColor = UIColor.magenta.cgColor
//        guideLayer.opacity = 0.5
        view.layer.addSublayer(guideLayer)
    }
    
    func setupGestures(){
        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:)))
        panRecognizer?.maximumNumberOfTouches = 1
        view.addGestureRecognizer(panRecognizer!)
        pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(self.handlePinch(_:)))
        view.addGestureRecognizer(pinchRecognizer!)
    }
    
//    override func mouseDragged(with event: NSEvent) {
//
//        let translation = CGPoint(x: translation.x - event.deltaX, y: translation.y - event.deltaY)
//        viewRect.layer?.position = translation
//        self.translation = translation
//        renderer?.updatePan(translation)
//
//    }
    
    var startPosition: CGPoint!
    var endPosition: CGPoint!
    
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
            
            
            let translation = CGPoint(x: translation.x - dX, y: translation.y - dY)
            
            self.renderer?.updatePan(translation, updateDelegate: false)
            endPosition = translation
        case.ended, .cancelled, .failed:
            translation = endPosition

        default:
            print("do nothing with gesture state \(recognizer.state)")
        }
    }
    
    //    override func scrollWheel(with event: NSEvent) {
    //
    //        totalYScale += event.scrollingDeltaY
    //        let yScale: CGFloat = totalYScale / 100
    //        viewRect.layer?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    //        viewRect.layer?.position = translation
    //        viewRect.layer?.setAffineTransform(.init(scaleX: yScale, y: yScale))
    //        viewRect.setNeedsDisplay(viewRect.bounds)
    //        translation = viewRect.layer?.position
    //        renderer?.viewState.setZoom(viewRect.layer!.frame)
    //    }
    
    @objc
    func handlePinch(_ recognizer: UIPinchGestureRecognizer){
        
//        switch(recognizer.state){
//        case .began,.changed:
//            let scale = recognizer.scale
//            guideLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5) //TODO: centerAnchor
//            guideLayer.setAffineTransform(.init(scaleX: scale, y: scale))
////            self.view.layer.setNeedsLayout()
////            self.view.layer.layoutSublayers()
//            renderer?.updateZoom(guideLayer.frame)
//            recognizer.scale = 1.0
//        default:
//            print("do nothing gestureState: \(recognizer.state)")
//        }
//
    }
    
}

extension MetalBrotViewController: MetalViewUpdateDelegate {
    func translationDidUpdate(point: CGPoint) {
        translation = point
        guideLayer.position = point
    }
}
