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
            SidebarView(
                faviconService: browserVM.faviconService,
                tabs: $browserVM.tabs,
                clickedTab: { tab in
                    /// if same just exit early
                    if browserVM.selectedTab?.id == tab.id { return }
                    browserVM.select(id: tab.id)
                },
                closeTab: { tab in
                    browserVM.closeTab(id: tab.id)
                }
            )
            .frame(maxWidth: 200, maxHeight: .infinity, alignment: .top)
        }
    }
}


/// Keeping this in a VM lets me NOT redraw the entire sidebarRow
/// for example when toggling isSelected
@Observable
final class SidebarRowViewModel {
    var faviconService: FaviconService
    var tab: Tab
    var isSelected = false
    var closeTab: (Tab) -> Void
    var clickedTab: (Tab) -> Void

    init(
        faviconService: FaviconService,
        tab: Tab,
        closeTab: @escaping (Tab) -> Void,
        clickedTab: @escaping (Tab) -> Void
    ) {
        self.faviconService = faviconService
        self.tab = tab
        self.closeTab = closeTab
        self.clickedTab = clickedTab
    }
}

struct SidebarRow: View {
    
    @Bindable var vm: SidebarRowViewModel
    
    var color: Color {
        vm.isSelected
        ? .white.opacity(0.45)
        : .white.opacity(0.18)
    }
    
    var strokeColor: Color {
        Color.white.opacity(vm.isSelected ? 0.25 : 0)
    }
    
    var body: some View {
        HStack {
            if let icon = vm.faviconService.favicon(for: vm.tab.url) {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 16, height: 16)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            Text(vm.tab.title)
            
            Spacer()
            
            Button {
                vm.closeTab(vm.tab)
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
                .fill(color)
                .background {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(strokeColor)
                }
                .animation(.snappy(duration: 0.18), value: vm.isSelected)
        }

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
        SidebarView(
            //        SidebarContent(
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
    .frame(width: 200, height: 510)
}
