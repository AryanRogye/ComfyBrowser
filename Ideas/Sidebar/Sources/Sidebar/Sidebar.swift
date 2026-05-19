// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        Text("Hello")
            .frame(width: 300, height: 200)
    }
}
