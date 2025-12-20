//
//  ComfyBrowserTopDashboard.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 8/23/25.
//

import SwiftUI

struct ComfyBrowserTopDashboard: View {
    
    @EnvironmentObject var viewModel: ComfyBrowserViewModel
    
    var body: some View {
        VStack {
            if let response = viewModel.requestedRequest {
                HStack(spacing: 12) {
                    Text(response.url?.absoluteString ?? "No URL")
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .truncationMode(.middle)
                    
                    Spacer()
                    
                    // Cancel Button
                    Button(action: {
                        viewModel.clearRequestedRequest()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                            .font(.system(size: 20))
                    }
                    .buttonStyle(.plain)
                    
                    // Confirm Button
                    Button(action:viewModel.useRequestedRequest) {
                        Image(systemName: "arrow.right.circle.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 20))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                )
                .padding(.horizontal)
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.easeInOut, value: response)
            } else {
                if let request = viewModel.currentRequest {
                    Button(action: {
                        /// Copy To Users Clipboard
                        UIPasteboard.general.string = request.url?.absoluteString
                    }) {
                        Text(request.url?.absoluteString ?? "No Request Yet")
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .truncationMode(.middle)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        //        if let response = viewModel.newTabResponse {
        //        }
    }
}
