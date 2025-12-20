//
//  ComfyBrowserApp.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 8/22/25.
//

import SwiftUI

@main
struct ComfyBrowserApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView(appEnv: AppEnv())
        }
    }
}

#Preview {
    NavigationView(appEnv: AppEnv())
}
