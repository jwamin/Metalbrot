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

extension Color {
  func metalClearColor()->MTLClearColor{
    
    let colors = self.cgColor.components!.map({ color in
        return Double(color)
    })
    
    return MTLClearColor(red: colors[0], green: colors[1], blue: colors[2], alpha: colors[3])
    
  }
}
