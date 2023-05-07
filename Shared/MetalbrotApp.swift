//
//  MetalbrotApp.swift
//  Shared
//
//  Created by Joss Manger on 6/11/22.
//

import SwiftUI
import MetalKit

class PrintManager {
    
    static let shared = PrintManager()
    
    private init() { }
    
    public private(set) var printView: MTKView?
    func setPrintView(_ metalKitView: MTKView?){
        printView = metalKitView
    }
}

@main
struct MetalbrotApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
                .edgesIgnoringSafeArea(.all)
        }
        #if !os(tvOS)
        .commands(content: {
            CommandGroup(after: .newItem) {
                Button("Print",action: {
                    #if os(macOS)
                    PrintManager.shared.printView?.printView(nil)
                    #else
                    #endif
                })
            }
        })
        #endif
    }
}
