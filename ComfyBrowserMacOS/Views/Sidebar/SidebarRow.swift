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
                    Image(systemName: "xmark")
                }
                .buttonStyle(SidebarRowMinusButtonStyle())
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
