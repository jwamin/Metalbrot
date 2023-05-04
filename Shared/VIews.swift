//
//  Views.swift
//  Metalbrot
//
//  Created by Joss Manger on 5/4/23.
//

import SwiftUI

#if os(macOS)
import Cocoa
typealias VCRepresentable = NSViewControllerRepresentable
#elseif os(iOS)
import UIKit
typealias VCRepresentable = UIViewControllerRepresentable
#elseif targetEnvironment(macCatalyst)
import UIKit
#endif


struct SwiftUIMetalKitView: VCRepresentable {

#if os(macOS)
    typealias NSViewControllerType = MetalbrotViewController
    typealias NSViewType = NSView
    
    func makeNSViewController(context: Context) -> MetalbrotViewController {
        MetalbrotViewController()
    }
    
    func updateNSViewController(_ nsViewController: MetalbrotViewController, context: Context) {
        print("view updated")
    }
    
    func makeCoordinator() -> Bool? {
        true
    }

#elseif os(iOS) || targetEnvironment(macCatalyst)
    typealias UIViewControllerType = MetalbrotViewController
    typealias UIViewType = UIView
    
    func makeUIViewController(context: Context) -> MetalbrotViewController {
        MetalbrotViewController()
    }
    
    func updateUIViewController(_ uiViewController: MetalbrotViewController, context: Context) {
        print("view updated")
    }
    
    func makeCoordinator() -> Setting {
        Setting()
    }
    
    #endif
    
}

struct SwiftUIMetalKitView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIMetalKitView()
    }
}
