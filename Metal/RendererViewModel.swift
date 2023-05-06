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
    var zoomLevel: Int { get }
    var zoomLevelPublished: Published<Int> { get }
    var zoomLevelPublisher: Published<Int>.Publisher { get }
    
    //Monstrous @Published Protocol Adapter
    var center: CGPoint { get }
    var centerPublished: Published<CGPoint> { get }
    var centerPublisher: Published<CGPoint>.Publisher { get }
    
    func updateCenter(_ newPoint: CGPoint)
    func updateZoom(_ newZoomLevel: Int)
    
    func getAdjustedSize(viewSize: vector_uint2) -> vector_uint2
    func getAdjustedPosition(viewSize: vector_uint2) -> vector_int2
    
}


final class MetalbrotRendererViewModel: MetalbrotViewModelInterface {

    
    //MetalbrotViewModelInterface protocol conformance
    var zoomLevel: Int { zoomLevelConcretePublished }
    var zoomLevelPublished: Published<Int> { _zoomLevelConcretePublished }
    var zoomLevelPublisher: Published<Int>.Publisher { $zoomLevelConcretePublished }
    
    var center: CGPoint { centerConcretePublished }
    var centerPublished: Published<CGPoint> { _centerConcretePublished }
    var centerPublisher: Published<CGPoint>.Publisher { $centerConcretePublished }
    
    //GET
    func getAdjustedSize(viewSize: vector_uint2) -> vector_uint2 {
        //let zoomSize: vector_uint2 = view.frame.size.vector_uint2_32 &* 2
        viewSize / UInt32(zoomLevel)
    }
    
    func getAdjustedPosition(viewSize: vector_uint2) -> vector_int2 {
        //let origin: vector_uint2 = view.frame.origin.vector_uint2_32 &* 2
        [0 , 0]
    }
    
    //SET
    func updateCenter(_ newPoint: CGPoint){
        centerConcretePublished = newPoint
    }
    
    func updateZoom(_ newZoomLevel: Int){
        zoomLevelConcretePublished = newZoomLevel
    }
    
    
    
    //Concrete Implementation
    @Published private var zoomLevelConcretePublished: Int
    @Published private var centerConcretePublished: CGPoint
    
    init(){
        zoomLevelConcretePublished = 1
        centerConcretePublished = .zero
    }
    
}
