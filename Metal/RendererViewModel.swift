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
    
    func getAdjustedSize(viewSize: vector_uint2) -> vector_float2
    func getAdjustedPosition(viewSize: vector_uint2) -> vector_int2
    
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
    func getAdjustedSize(viewSize: vector_uint2) -> vector_float2 {
        //let zoomSize: vector_uint2 = view.frame.size.vector_uint2_32 &* 2
        // Int lacks precision here, needs to be decimal
        //print(zoomLevel)
        //        newX = x + width/2 - newWidth/2
        //        newY = y + height/2 - newHeight/2
        let signed_vector = vector_float2(Float(viewSize.x), Float(viewSize.y))
        let fixedZoomLevel = zoomLevel == 0 ? 1 : Float(zoomLevel)
        print(signed_vector, fixedZoomLevel, signed_vector * fixedZoomLevel)
        return signed_vector * fixedZoomLevel
    
    }
    
    func getAdjustedPosition(viewSize: vector_uint2) -> vector_int2 {
        //let origin: vector_uint2 = view.frame.origin.vector_uint2_32 &* 2
        let xWidth = Int32(viewSize.x / 2)
        let yHeight = Int32(viewSize.y / 2)
        let x = Int32(center.x) + xWidth - xWidth
        let y = Int32(center.y) + yHeight - yHeight
        return [-x , y]// &* Int32(zoomLevel)
    }
    
    //SET
    func updateCenter(_ newPoint: CGPoint){
        centerConcretePublished = newPoint
    }
    
    func updateZoom(_ newZoomLevel: CGFloat){
        zoomLevelConcretePublished += newZoomLevel
    }
    
    //Concrete Implementation
    @Published private var zoomLevelConcretePublished: CGFloat
    @Published private var centerConcretePublished: CGPoint
    
    init(){
        zoomLevelConcretePublished = 1
        centerConcretePublished = .zero
    }
    
}
