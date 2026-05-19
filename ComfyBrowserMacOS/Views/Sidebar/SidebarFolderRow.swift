//
//  SidebarFolderRow.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/19/26.
//

import SwiftUI

struct SidebarFolderRow: View {

    @Bindable var vm: SidebarFolderRowViewModel

    var body: some View {
        Rectangle()
            .fill(.clear)
            .stroke(.red)
            .padding()
            .overlay(alignment: .leading) {
                HStack {
                    Image(systemName: vm.folder.isExpanded ? "chevron.down" : "chevron.right")
                        .foregroundStyle(.secondary)
                    Image(systemName: "folder.fill")
                    Text(vm.folder.title)
                }
                .padding(.leading)
            }
    }
}
