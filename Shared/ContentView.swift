//
//  ContentView.swift
//  Shared
//
//  Created by Joss Manger on 6/11/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        SwiftUIMetalKitView()
            .frame(minWidth: 100, maxWidth: .infinity, minHeight: 100, maxHeight: .infinity, alignment: .center)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
