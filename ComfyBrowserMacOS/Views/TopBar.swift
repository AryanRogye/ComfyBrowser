//
//  TopBar.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 12/19/25.
//

import SwiftUI

struct TopBar<SidebarIcon: View>: View {
    
    @Environment(BrowserViewModel.self) var browserVM
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
                    browserVM.createTab(search)
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
