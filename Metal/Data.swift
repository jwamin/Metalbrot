//
//  Data.swift
//  Metalbrot
//
//  Created by Joss Manger on 6/16/22.
//

import simd

struct MetalbrotConstants {
    
    struct data {
        
        //vertices for full viewport coverage
        static let vertices:[vector_float2] = [
            [-1.0,-1.0],
            [-1.0,1.0],
            [1.0,-1.0],
            [1.0,1.0]
        ]
        
        //Colors for debugging
        static let colors:[vector_float4] = [
            [1, 0, 0, 1],
            [0, 1, 0, 1],
            [0, 0, 1, 1],
            [1, 1, 1, 1],
        ]
        
    }
    
}
