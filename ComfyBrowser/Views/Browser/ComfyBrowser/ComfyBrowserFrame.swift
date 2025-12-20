//
//  ComfyBrowserFrame.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 8/23/25.
//

import SwiftUI

struct ComfyBrowserFrame<
    TopContent: View,
    MainContent: View,
    BottomContent: View
>: View {
    
    var topContent: TopContent
    var mainContent: MainContent
    var bottomContent: BottomContent
    
    init(
        @ViewBuilder topContent: @escaping () -> TopContent,
        @ViewBuilder mainContent: @escaping () -> MainContent,
        @ViewBuilder bottomContent: @escaping () -> BottomContent
    ) {
        self.topContent = topContent()
        self.mainContent = mainContent()
        self.bottomContent = bottomContent()
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 0) {
                topContent
                
                mainContent
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding()
                
                bottomContent
            }
        }
    }
}
