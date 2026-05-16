//
//  TopBar.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 12/19/25.
//

import SwiftUI

struct TopBar<SidebarIcon: View>: View {
    
    @Environment(BrowserCoordinator.self) var browserController
    @Binding var shouldShowSidebarIcon: Bool
    @ViewBuilder var sidebarIcon: SidebarIcon
    @State private var search: String = ""
    
    var body: some View {
        HStack {
            if shouldShowSidebarIcon {
                sidebarIcon
            }
            TextField("", text: $search)
                .textFieldStyle(.plain)
                .onSubmit {
                    if search.isEmpty { return }
                    browserController.createTab(search)
                }
            
            Spacer()
        }
        .padding(.horizontal, 8)
        .foregroundStyle(.black)
        .frame(maxWidth: .infinity, maxHeight: 40)
        .background(.regularMaterial)
        .clipShape(
            .rect(
                topLeadingRadius: 8,
                topTrailingRadius: 8
            )
        )
        .animation(.snappy(duration: 0.2), value: shouldShowSidebarIcon)
    }
}
