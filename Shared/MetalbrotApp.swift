//
//  MetalbrotApp.swift
//  Shared
//
//  Created by Joss Manger on 6/11/22.
//

import SwiftUI
import MetalKit

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
                Button("Print") {
                    #if os(macOS)
                    if let printView = PrintManager.shared.printView {
                        printView.printView(nil)
                    }
                    #endif
                }
            }
        })
        #endif
    }
}

// Simple singleton for managing print view reference
class PrintManager {
    static let shared = PrintManager()
    private init() { }
    
    var printView: MTKView?
    
    func setPrintView(_ view: MTKView?) {
        printView = view
    }
}
