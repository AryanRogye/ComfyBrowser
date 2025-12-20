//
//  NavigationView.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 8/22/25.
//

import SwiftUI


enum NavigationItems {
    case gridView
    case browserView(tab: Tab)
}

class NavigationViewModel: ObservableObject {
    @Published var selectedItem: NavigationItems
    
    init() {
        self.selectedItem = .gridView
    }
}

struct NavigationView: View {
    
    let appEnv: AppEnv
    
    @StateObject var navigationViewModel = NavigationViewModel()
    
    @StateObject var gridViewModel : GridViewModel
    
    init(appEnv: AppEnv) {
        
        self.appEnv = appEnv
        _gridViewModel = StateObject(wrappedValue: GridViewModel(deps: appEnv))
    }
    
    var body: some View {
        Group {
            /// View Of What We're Showing
            switch navigationViewModel.selectedItem {
            case .gridView: GridView()
            case .browserView(let tab): BrowserView(tab: tab)
                    .environmentObject(TabViewModel(tab: tab, deps: appEnv))
            }
        }
        .environmentObject(navigationViewModel)
        .environmentObject(gridViewModel)
    }
}
