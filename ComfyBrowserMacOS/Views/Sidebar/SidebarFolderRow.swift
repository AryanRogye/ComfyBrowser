//
//  SidebarFolderRow.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/19/26.
//

import SwiftUI

struct SidebarFolderRow: View {

    @Bindable var vm: SidebarFolderRowViewModel

    var color: Color {
        vm.isHovered
        ? .white.opacity(0.66)
        : .white.opacity(0.18)
    }

    var strokeColor: Color {
        .white.opacity(vm.isHovered ? 0.28 : 0)
    }

    var indentationLevel: CGFloat {
        return CGFloat(vm.indentationLevel) * 14
    }

    var body: some View {
        HStack(spacing: 8) {
            AnimatedFolderIcon(
                isOpen: $vm.folder.isExpanded,
                isHovered: vm.isHovered
            )
            .frame(width: 16, height: 15)

            Text(vm.folder.title)
            Spacer()
        }
        .lineLimit(1)
        .padding(.leading)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(strokeColor)
                }
        }
        .offset(x: indentationLevel)
    }
}
