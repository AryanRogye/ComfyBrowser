//
//  SearchSuggestionRow.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/16/26.
//

import SwiftUI

/// Renders one omnibar suggestion row.
///
/// This view is intentionally dumb: it does not decide what selecting a row
/// means. It only renders the `SearchSuggestion` value.
///
/// Example:
///     `.openTab` rows show a window icon, `.history` rows show a clock icon.
struct SearchSuggestionRow: View {
    
    @Bindable var vm: SearchSuggestionRowViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            icon
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(vm.suggestion.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                if let subtitle = vm.suggestion.subtitle {
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background {
            if vm.isHovering {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.primary.opacity(0.08))
            }
        }
        .contentShape(Rectangle())
    }
    
    @ViewBuilder
    private var icon: some View {
        if let icon = vm.faviconService.favicon(for: vm.suggestion.url) {
            Image(nsImage: icon)
                .resizable()
                .frame(width: 16, height: 16)
                .clipShape(RoundedRectangle(cornerRadius: 6))
        } else {
            Image(systemName: systemImage)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
        }
    }
    
    private var systemImage: String {
        switch vm.suggestion.kind {
        case .openTab:
            return "macwindow"
        case .history:
            return "clock.arrow.circlepath"
        case .url:
            return "globe"
        case .search:
            return "magnifyingglass"
        }
    }
}

#Preview {
    VStack {
        SearchSuggestionRow(
            vm: SearchSuggestionRowViewModel(
                faviconService: FaviconService(),
                suggestion: SearchSuggestion(
                    id: "preview",
                    kind: .history,
                    title: "ComfyBrowser",
                    subtitle: "github.com/AryanRogye/ComfyBrowser",
                    url: URL(string: "https://github.com/AryanRogye/ComfyBrowser"),
                    score: 1
                )
            )
        )
    }
    .padding()
    .frame(width: 420)
}
