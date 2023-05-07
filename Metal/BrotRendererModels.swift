//
//  BrotRendererModels.swift
//  Metalbrot
//
//  Created by Joss Manger on 5/6/23.
//

import Foundation
import simd

struct OriginZoom {
    
    var frame: CGRect
    
    enum Value{
        case origin
        case zoom
    }
    
    func getVector(_ value:Value) -> vector_int2 {
        
        switch value{
        case .origin:
            return vector_int2(x: Int32(frame.origin.x), y: Int32(frame.origin.y))
        case .zoom:
            return vector_int2(x: Int32(frame.size.width), y: Int32(frame.size.height))
        }
        
    }
    
    mutating func setPosition(_ newPosition: CGPoint){
        let newOrigin = CGPoint(x: newPosition.x - (frame.size.width / 2), y: newPosition.y - (frame.size.height / 2))
        frame = CGRect(origin: newOrigin, size: frame.size)
    }
    
    mutating func setZoom(_ newZoom: CGRect){
        frame = newZoom
    }
    
    static var zero: OriginZoom = OriginZoom(frame: .zero)
    
}

extension OriginZoom: CustomStringConvertible {
    var description: String{
        "\(frame)"
    }
}
