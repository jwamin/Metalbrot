//
//  Models.swift
//  Metalbrot
//
//  Created by Joss Manger on 6/16/22.
//

import Foundation

typealias Blob = (Float,Float,Float,Float,Float,Float)

struct ColoredVertex{
    
    let position:SIMD2<Float>
    let color:SIMD4<Float>
    
    init(with blob:Blob) {
        position = [blob.0,blob.1]
        color = [blob.2,blob.3,blob.4,blob.5]
    }
    
    
}

struct BasicVertex {
    
    let position:SIMD2<Float>
    
}
