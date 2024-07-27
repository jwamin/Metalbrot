//
//  Extensions.swift
//  Metalbrot
//
//  Created by Joss Manger on 5/4/23.
//

#if os(macOS)
import Cocoa
typealias Color = NSColor
#else
import UIKit
typealias Color = UIColor
#endif

import simd

extension MTLClearColor {
    subscript(index: Int) -> Double {
        get {
            switch(index){
            case 0:
                return self.red
            case 1:
                return self.green
            case 2:
                return self.blue
            case 3:
                return self.alpha
            default:
                fatalError("metal clear color element out of range")
            }
        }
        set(newValue){
            switch(index){
            case 0:
                self.red = newValue
            case 1:
                self.green = newValue
            case 2:
                self.blue = newValue
            case 3:
                self.alpha = newValue
            default:
                fatalError("metal clear color element out of range")
            }
        }
    }
}

extension Color {
    
  func metalClearColor() -> MTLClearColor {
    
      var metalClearColor = MTLClearColor()
      self.cgColor.components!.enumerated().forEach({ (index,color) in
          metalClearColor[index] = Double(color)
      })
    
    return metalClearColor
    
  }
    
    func float4() -> vector_float4 {
        vector_float4(self.cgColor.components!.map({Float($0)}))
    }
    
}

fileprivate let internalPrivateColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)

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
