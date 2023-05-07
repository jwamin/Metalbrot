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
    
    func getAdjustedSize(viewSize: vector_uint2) -> vector_int2
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
    func getAdjustedSize(viewSize: vector_uint2) -> vector_int2 {
        //let zoomSize: vector_uint2 = view.frame.size.vector_uint2_32 &* 2
        // Int lacks precision here, needs to be decimal
        print(zoomLevel)
        let signed_vector = vector_int2(Int32(viewSize.x), Int32(viewSize.y))
        let fixedZoomLevel = zoomLevel == 0 ? 1 : Int32(zoomLevel)
        return signed_vector / fixedZoomLevel
    
    }
    
    func getAdjustedPosition(viewSize: vector_uint2) -> vector_int2 {
        //let origin: vector_uint2 = view.frame.origin.vector_uint2_32 &* 2
        [0 , 0] &* Int32(zoomLevel)
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
