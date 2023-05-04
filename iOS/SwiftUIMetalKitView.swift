//
//  SwiftUIMetalKitView.swift
//  Metalbrot (iOS)
//
//  Created by Joss Manger on 5/4/23.
//

import SwiftUI

class Setting {
    let bool: Bool
    init(newBool: Bool = false){
        self.bool = newBool
    }
}


struct SwiftUIMetalKitView: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = MetalBrotViewController
    typealias UIViewType = UIView
    
    func makeUIViewController(context: Context) -> MetalBrotViewController {
        MetalBrotViewController()
    }
    
    func updateUIViewController(_ uiViewController: MetalBrotViewController, context: Context) {
        print("view updated")
    }
    
    func makeCoordinator() -> Setting {
        Setting()
    }
    
}

struct SwiftUIMetalKitView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIMetalKitView()
    }
}
