//
//  SidebarRow.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/16/26.
//

import SwiftUI

struct SidebarRow: View {
    
    @Bindable var vm: SidebarRowViewModel
    
    var color: Color {
        vm.selectedTab?.id == vm.tab.id
        ? .white.opacity(0.9)
        : (
            vm.isHovered
            ? .white.opacity(0.66)
            : (vm.isSelected
               ? .white.opacity(0.45)
               : .white.opacity(0.18)
            )
        )
    }

    var strokeColor: Color {
        Color.white.opacity(vm.isHovered ? 2 : ( vm.isSelected ? 0.25 : 0))
    }

    var indentationLevel: CGFloat {
        return CGFloat(vm.indentationLevel ?? 0) * 14
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
            
            if vm.isHovered {
                Button {
                    vm.closeTab(vm.tab)
                } label: {
                    HoverBackground(
                        innerColor: .black.opacity(0.1),
                        outerColor: .white.opacity(0.18)
                    ) {
                        Image(systemName: "xmark")
                            .padding(4)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .lineLimit(1)
        .padding(6)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 6)
                .fill(color)
                .background {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(strokeColor)
                }
                .animation(.snappy(duration: 0.18), value: vm.isSelected)
        }
        .offset(x: indentationLevel)
    }
}
