//
//  Extensions.swift
//  Metalbrot
//
//  Created by Joss Manger on 5/4/23.
//

import Foundation

extension MetalbrotViewController: MetalViewUpdateDelegate {
    
    func translationDidUpdate(point: CGPoint) {
        translation = point
    }
    
}
