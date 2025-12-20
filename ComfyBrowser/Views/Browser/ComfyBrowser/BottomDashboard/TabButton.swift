//
//  TabButton.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 8/23/25.
//


import SwiftUI

struct TabButton: View {
    
    @EnvironmentObject var viewModel: ComfyBrowserViewModel
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    
    var body: some View {
        Button(action: {
            navigationViewModel.selectedItem = .gridView
        }) {
            ZStack {
                HStack {
                    Image(systemName: "square.grid.2x2")
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                )
            }
        }
        .buttonStyle(.plain)
        .overlay(alignment: .topTrailing) {
            Text("\(viewModel.getCurrentTabCount())")
                .foregroundColor(.white)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .padding(4)
                .background(Circle().fill(Color.black))
                .offset(x: 6, y: -6) // fine-tune position
        }
    }
}
