//
//  SidebarFolderRow.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/18/26.
//

import SwiftUI

struct SidebarFolderRow: View {
    var folder: TabFolder
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: folder.isExpanded ? "chevron.down" : "chevron.right")
                .font(.system(size: 10, weight: .semibold))
                .frame(width: 12)
            
            Image(systemName: "folder")
                .font(.system(size: 14, weight: .semibold))
            
            Text(folder.title)
                .lineLimit(1)
            
            Spacer()
        }
        .padding(6)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 6)
                .fill(.white.opacity(0.12))
        }
    }
}
