//
//  ContentView.swift
//  ch3renderPipeline
//
//  Created by Alexander Williams on 3/6/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            MetalView()
              .border(Color.black, width: 2)
            Text("Hello, Metal!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
