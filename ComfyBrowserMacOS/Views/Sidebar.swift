//
//  Sidebar.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 12/19/25.
//

import SwiftUI

struct Sidebar: View {

    @Environment(ComfyBrowserViewModel.self) var comfyBrowserVM
    @Bindable var browserVM : BrowserViewModel


    var body: some View {
        @Bindable var comfyBrowserVM = comfyBrowserVM

        if comfyBrowserVM.sidebarState == .open {
            SidebarContent(tabs: $browserVM.tabs) { tab in
                browserVM.select(tab: tab)
            }
        }
    }
}

/// This is a temp I want this to be AppKit
struct SidebarContent: View {

    @Binding var tabs : [Tab]
    var clickedTab: (Tab) -> Void

    let distanceFromTop: CGFloat = 40

    var backgroundColor: some ShapeStyle {
        LinearGradient(
            colors: [.pink.opacity(0.5), .red.opacity(0.5)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    var body: some View {
        VStack {
            ForEach(tabs) { tab in
                Button {
                    print("clicked tab")
                    clickedTab(tab)
                } label: {
                    Text(tab.title)
                        .lineLimit(1)
                        .padding(6)
                        .frame(maxWidth: .infinity)
                        .background {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(.white.opacity(0.3))
                        }
                        .padding(.horizontal, 4)
                }
                .buttonStyle(SidebarRowButtonStyle())
            }
        }
        .frame(maxWidth: 200, maxHeight: .infinity, alignment: .top)
        .padding(.top, distanceFromTop)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .fill(backgroundColor)
                .stroke(.white.opacity(0.3), style: .init(lineWidth: 1))
        }
    }
}

struct SidebarRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}


#Preview {
    VStack {
        SidebarContent(
            tabs: .constant([
                .init(
                    title: "DuckDuckGo",
                    url: URL(string: "https://duckduckgo.com")!,
                    isActive: true
                ),
                .init(
                    title: "GitHub",
                    url: URL(string: "https://github.com")!,
                    isActive: false
                ),
                .init(
                    title: "UIC Blackboard",
                    url: URL(string: "https://uic.blackboard.com")!,
                    isActive: false
                )
            ])
        ) { tab in
        }
        .padding()
    }
    .frame(height: 510)
}
