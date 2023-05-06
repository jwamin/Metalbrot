//
//  Helpers.swift
//  Metalbrot
//
//  Created by Joss Manger on 6/11/22.
//

#if os(macOS)
import Cocoa
typealias Color = NSColor
#else
import UIKit
typealias Color = UIColor
#endif

import simd

extension Color {
    
  func metalClearColor() -> MTLClearColor {
    
    let colors = self.cgColor.components!.map({ color in
        return Double(color)
    })
    
    return MTLClearColor(red: colors[0], green: colors[1], blue: colors[2], alpha: colors[3])
    
  }
    
}

protocol PositionInSuperView {
    
    var positionInSuperView: CGPoint {
        get
    }
    
    var center: CGPoint {
        get
    }
    
}

extension CGRect: PositionInSuperView {
    var center: CGPoint {
        CGPoint(x: self.width / 2, y: self.height / 2)
    }
    
    var positionInSuperView: CGPoint{
        CGPoint(x: self.midX, y: self.midY)
    }
}

extension CGSize: PositionInSuperView {
    var center: CGPoint {
        CGPoint(x: self.width / 2, y: self.height / 2)
    }
    
    var positionInSuperView: CGPoint{
        center
    }
    
    var vector_uint2_32: vector_uint2 {
        [UInt32(self.width),UInt32(self.height)]
    }
    
}

extension CGPoint {
    var vector_uint2_32: vector_uint2 {
        [UInt32(self.x),UInt32(self.y)]
    }
    
}
