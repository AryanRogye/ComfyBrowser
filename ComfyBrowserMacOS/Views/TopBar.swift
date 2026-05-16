//
//  TopBar.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 12/19/25.
//

import SwiftUI

struct TopBar<SidebarIcon: View>: View {
    
    let searchEngine: SearchEngine
    @Binding var shouldShowSidebarIcon: Bool
    @ViewBuilder var sidebarIcon: SidebarIcon
    var onSearch: (String) -> Void
    
    @FocusState private var isFocused: Bool
    @State private var isSearchOverlayVisible: Bool = false
    @State private var search: String = ""

    var body: some View {
        ZStack(alignment: .topLeading) {
            if isSearchOverlayVisible {
                focusedSearchOverlay
                    .zIndex(0)
            }
            
            HStack {
                if shouldShowSidebarIcon {
                    sidebarIcon
                }
                
                textfield
                
                Spacer()
            }
            .padding(.horizontal, 8)
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .background {
                if !isSearchOverlayVisible {
                    Rectangle()
                        .fill(.regularMaterial)
                }
            }
            .clipShape(
                .rect(
                    topLeadingRadius: 8,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 8
                )
            )
            .contentShape(Rectangle())
            .zIndex(1)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 40, alignment: .topLeading)
        .zIndex(isSearchOverlayVisible ? 10 : 1)
        .animation(.snappy(duration: 0.2), value: shouldShowSidebarIcon)
        .animation(.snappy(duration: 0.2), value: isSearchOverlayVisible)
    }
    
    private var textfield: some View {
        HStack(alignment: .center) {
            searchIcon
            TextField("Search with \(searchEngine.rawValue) or enter address", text: $search)
                .textFieldStyle(.plain)
                .foregroundStyle(.black)
                .onSubmit {
                    if search.isEmpty { return }
                    onSearch(search)
                    isFocused = false
                }
                .focused($isFocused)
                .onChange(of: isFocused) { _, newValue in
                    if !newValue {
                        isSearchOverlayVisible = false
                        return
                    }
                    isSearchOverlayVisible = true
                    if !isSearchOverlayVisible || search.isEmpty { return }
                    TextFieldSelectAll.selectAll()
                }
        }
        .padding(.leading, 8)
        .frame(height: 40)
        .contentShape(Rectangle())
        .simultaneousGesture(
            TapGesture().onEnded {
                isSearchOverlayVisible = true
                isFocused = true
            }
        )
        .animation(.snappy(duration: 0.2), value: isSearchOverlayVisible)
    }
    
    private var searchIcon: some View {
        Image(systemName: "magnifyingglass")
            .foregroundStyle(.black)
    }
    
    private var focusedSearchOverlay: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.white)
            .shadow(color: .black.opacity(0.14), radius: 16, x: 0, y: 8)
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.black.opacity(0.06), lineWidth: 1)
            }
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(.black.opacity(0.12))
                    .frame(height: 1)
                    .padding(.horizontal, 20)
                    .padding(.top, 48)
            }
            .frame(height: 172)
            .padding(.horizontal, 8)
            .allowsHitTesting(false)
    }
}

#Preview {
    
    @Previewable @State var comfyBrowserViewModel = ComfyBrowserViewModel()
    @Previewable @State var browserCoordinator = BrowserCoordinator()
    
    VStack {
        TopBar(
            searchEngine: .duckDuckGo,
            shouldShowSidebarIcon: .constant(true),
            sidebarIcon: {
                SidebarIcon(action: comfyBrowserViewModel.toggleSidebarOpenClose)
            }, onSearch: { search in
                
            })
        .padding()
    }
    .frame(width: 400, height: 500)
}
