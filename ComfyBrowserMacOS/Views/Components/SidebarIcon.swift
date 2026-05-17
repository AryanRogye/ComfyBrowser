//
//  SidebarIcon.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 12/19/25.
//

import SwiftUI

struct SidebarIcon: View {

    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HoverBackground {
                Image(systemName: "sidebar.left")
                    .resizable()
                    .frame(width: 21, height: 17)
                    .padding(.horizontal, 3)
                    .padding(.vertical, 3)
            }
        }
        .buttonStyle(.plain)
    }
}
