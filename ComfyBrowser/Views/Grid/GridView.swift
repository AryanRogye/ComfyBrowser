//
//  GridView.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 8/22/25.
//

import SwiftUI

struct GridView: View {
    
    @EnvironmentObject private var viewModel: GridViewModel
    @EnvironmentObject private var navigationViewModel: NavigationViewModel
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            ScrollView {
                tabGridView
            }
            
            VStack {
                Spacer()
                bottomBar
            }
            .padding(.horizontal)
        }
    }
    
    private var bottomBar: some View {
        HStack {
            Spacer()
            Button(action: {
                viewModel.createNewTab()
            }) {
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .padding(24)
                    .background(Color.blue)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
        }
    }
    
    // MARK: - Tab Grid View
    private var tabGridView: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(viewModel.tabs) { tab in
                Button(action: {
                    /// We Set the selected item to the tab view with the tab
                    navigationViewModel.selectedItem = .browserView(tab: tab)
                }) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue)
                        .frame(height: 150)
                        .overlay(
                            Text(tab.title)
                                .foregroundColor(.white)
                                .bold()
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
    }
}
