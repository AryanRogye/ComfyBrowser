//
//  ComfyBrowserBottomDashboard.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 8/23/25.
//

import SwiftUI

struct ComfyBrowserBottomDashboard: View {
    var body: some View {
        HStack {
            SearchBar()
            TabButton()
        }
        .padding(.horizontal, 24)
    }
}
