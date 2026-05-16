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
            SidebarContent(
                faviconService: browserVM.faviconService,
                tabs: $browserVM.tabs,
                clickedTab: { tab in
                    browserVM.select(id: tab.id)
                },
                closeTab: { tab in
                    browserVM.closeTab(id: tab.id)
                }
            )
//        )
        }
    }
}

/// This is a temp I want this to be AppKit
struct SidebarContent: View {

    @Bindable var faviconService: FaviconService
    @Binding var tabs : [Tab]
    var clickedTab: (Tab) -> Void
    var closeTab: (Tab) -> Void

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
                    HStack {
                        if let icon = faviconService.favicon(for: tab.url) {
                            Image(nsImage: icon)
                                .resizable()
                                .frame(width: 16, height: 16)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                        Text(tab.title)
                        
                        Spacer()
                        
                        Button {
                            closeTab(tab)
                        } label: {
                            Image(systemName: "xmark")
                        }
                        .buttonStyle(SidebarRowMinusButtonStyle())
                    }
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

struct SidebarRowMinusButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(2)
            .background {
                if configuration.isPressed {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.white.opacity(0.2))
                } else {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.white.opacity(0.4))
                }
            }
            .animation(.snappy, value: configuration.isPressed)
    }
}


#Preview {
    VStack {
        SidebarContent(
            faviconService: FaviconService(),
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
        ) { tab in } closeTab: { tab in }
        .padding()
    }
    .frame(height: 510)
}
