//
//  RendererViewModel.swift
//  Metalbrot
//
//  Created by Joss Manger on 5/6/23.
//

import Foundation
import simd
import Combine

protocol MetalbrotViewModelInterface: AnyObject {
    
    //Monstrous @Published Protocol Adapter
    var zoomLevel: CGFloat { get }
    var zoomLevelPublished: Published<CGFloat> { get }
    var zoomLevelPublisher: Published<CGFloat>.Publisher { get }
    
    //Monstrous @Published Protocol Adapter
    var center: CGPoint { get }
    var centerPublished: Published<CGPoint> { get }
    var centerPublisher: Published<CGPoint>.Publisher { get }
    
    func updateCenter(_ newPoint: CGPoint)
    func updateZoom(_ newZoomLevel: CGFloat)
    func setZoom(_ newZoomLevel: CGFloat)
    
    func requestUpdate()
    
    func getAdjustedRect(viewSize: vector_uint2) -> (vector_int2, vector_float2)
    
}


final class MetalbrotRendererViewModel: MetalbrotViewModelInterface {

    //MetalbrotViewModelInterface protocol conformance
    var zoomLevel: CGFloat { zoomLevelConcretePublished }
    var zoomLevelPublished: Published<CGFloat> { _zoomLevelConcretePublished }
    var zoomLevelPublisher: Published<CGFloat>.Publisher { $zoomLevelConcretePublished }
    
    var center: CGPoint { centerConcretePublished }
    var centerPublished: Published<CGPoint> { _centerConcretePublished }
    var centerPublisher: Published<CGPoint>.Publisher { $centerConcretePublished }
    
    //GET
    func getAdjustedRect(viewSize: vector_uint2) -> (vector_int2, vector_float2) {
        
        let signed_vector = vector_float2(Float(viewSize.x), Float(viewSize.y))
        let fixedZoomLevel = zoomLevel == 0 ? 1 : Float(zoomLevel)
        let newSize = signed_vector * fixedZoomLevel
        
        let xWidth = Int32(viewSize.x / 2)
        let yHeight = Int32(viewSize.y / 2)
        let xWidthN = Int32(newSize.x / 2)
        let yHeightN = Int32(newSize.y / 2)
        let x = Int32(center.x) + xWidth - xWidthN
        let y = Int32(center.y) + yHeight - yHeightN
        return ([x , y], [newSize.x, newSize.y])
    }
    
    //SET
    func updateCenter(_ newPoint: CGPoint){
        centerConcretePublished = newPoint
    }
    
    func updateZoom(_ newZoomLevel: CGFloat){
        zoomLevelConcretePublished += newZoomLevel
    }
    
    func setZoom(_ newZoomLevel: CGFloat){
        zoomLevelConcretePublished = newZoomLevel
    }
    
    func requestUpdate() {
        let concrete = zoomLevel
        zoomLevelConcretePublished = concrete
    }
    
    //Concrete Implementation
    @Published private var zoomLevelConcretePublished: CGFloat
    @Published private var centerConcretePublished: CGPoint
    
    init(){
        zoomLevelConcretePublished = 1
        centerConcretePublished = .zero
    }
    
}
