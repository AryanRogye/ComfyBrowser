//
//  SearchBar.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 8/23/25.
//

import SwiftUI

struct SearchBar: View {
    
    @EnvironmentObject private var viewModel : ComfyBrowserViewModel
    
    var body: some View {
        HStack {
            Button(action: {
                viewModel.performSearch()
            }) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .padding(.leading, 8)
            }
            .buttonStyle(.plain)
            
            TextField("Search or enter URL", text: $viewModel.search, onCommit: {
                viewModel.performSearch()
            })
            .textFieldStyle(PlainTextFieldStyle())
            .padding(.vertical, 6)
            
            if !viewModel.search.isEmpty {
                Button(action: { viewModel.search = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
                .padding(.trailing, 8)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.9))
                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
        )
    }
}
