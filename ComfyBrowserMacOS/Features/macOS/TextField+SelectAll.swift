//
//  TextField+SelectAll.swift
//  ComfyBrowser
//
//  Created by Aryan Rogye on 5/16/26.
//

import SwiftUI

enum TextFieldSelectAll {
    public static func selectAll() {
        RunLoop.current.perform {
            NSApp.sendAction(#selector(NSText.selectAll(_:)), to: nil, from: nil)
        }
    }
}
