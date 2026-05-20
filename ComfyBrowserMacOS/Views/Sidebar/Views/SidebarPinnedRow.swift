//
//  SidebarPinnedRow.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/20/26.
//


import SwiftUI

struct SidebarPinnedRow: View {

    @Bindable var vm: SidebarRowViewModel

    var selected: Bool {
        vm.selectedTab?.id == vm.tab.id
    }

    var color: Color {
        selected
        ? .white.opacity(0.9)
        : (vm.isHovered
           ? .white.opacity(0.3)
           : .white.opacity(0.1)
        )
    }

    var strokeColor: Color {
        selected
        ? .white.opacity(0.1)
        : (vm.isHovered
           ? .black.opacity(0.1)
           : .white.opacity(0.1)
        )
    }

    var body: some View {
        if let icon = vm.faviconService.favicon(for: vm.tab.url) {
            Image(nsImage: icon)
                .resizable()
                .frame(width: 16, height: 16)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(strokeColor, lineWidth: 1)
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}
